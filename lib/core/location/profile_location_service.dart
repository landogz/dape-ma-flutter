import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../auth/auth_service.dart';
import '../network/endpoints.dart';

class ProfileLocation {
  const ProfileLocation({
    this.region,
    this.province,
    this.city,
    this.label,
    this.latitude,
    this.longitude,
  });

  final String? region;
  final String? province;
  final String? city;
  final String? label;
  final double? latitude;
  final double? longitude;

  bool get isEmpty =>
      (region == null || region!.trim().isEmpty) &&
      (province == null || province!.trim().isEmpty) &&
      (city == null || city!.trim().isEmpty);

  String get summary {
    final parts = <String>[
      if (city != null && city!.trim().isNotEmpty) city!.trim(),
      if (province != null && province!.trim().isNotEmpty) province!.trim(),
      if (region != null && region!.trim().isNotEmpty) region!.trim(),
    ];
    return parts.join(', ');
  }

  Map<String, dynamic> toProfilePayload() => {
        'region': region?.trim() ?? '',
        'province': province?.trim() ?? '',
        'city': city?.trim() ?? '',
      };

  factory ProfileLocation.fromJson(Map<String, dynamic> json) {
    String? read(String key) {
      final value = json[key]?.toString().trim();
      return (value == null || value.isEmpty) ? null : value;
    }

    return ProfileLocation(
      region: read('region'),
      province: read('province'),
      city: read('city'),
      label: read('label') ?? read('address'),
      latitude: double.tryParse('${json['latitude'] ?? json['lat'] ?? ''}'),
      longitude: double.tryParse('${json['longitude'] ?? json['lng'] ?? ''}'),
    );
  }
}

enum ProfileLocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
  reverseFailed,
}

class ProfileLocationException implements Exception {
  ProfileLocationException(this.failure, [this.message]);

  final ProfileLocationFailure failure;
  final String? message;
}

class ProfileLocationService {
  ProfileLocationService._();

  static Future<ProfileLocation> detectFromGps() async {
    final position = await _currentPosition();
    return reverseGeocode(position.latitude, position.longitude);
  }

  static Future<Position> _currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw ProfileLocationException(ProfileLocationFailure.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw ProfileLocationException(ProfileLocationFailure.permissionDenied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw ProfileLocationException(
        ProfileLocationFailure.permissionDeniedForever,
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on Exception catch (error) {
      throw ProfileLocationException(
        ProfileLocationFailure.unavailable,
        error.toString(),
      );
    }
  }

  static Future<ProfileLocation> reverseGeocode(double lat, double lng) async {
    try {
      final res = await AuthService.authedGet<Map<String, dynamic>>(
        Endpoints.geocodeReverse,
        query: {
          'lat': lat,
          'lng': lng,
        },
      );
      final root = res.data ?? <String, dynamic>{};
      final data = root['data'];
      if (data is! Map<String, dynamic>) {
        throw ProfileLocationException(ProfileLocationFailure.reverseFailed);
      }
      final place = ProfileLocation.fromJson(data);
      if (place.isEmpty) {
        throw ProfileLocationException(ProfileLocationFailure.reverseFailed);
      }
      return place;
    } on ProfileLocationException {
      rethrow;
    } on DioException catch (error) {
      throw ProfileLocationException(
        ProfileLocationFailure.reverseFailed,
        error.message,
      );
    } on Exception catch (error) {
      throw ProfileLocationException(
        ProfileLocationFailure.reverseFailed,
        error.toString(),
      );
    }
  }
}
