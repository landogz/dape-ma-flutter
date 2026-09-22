import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/auth/auth_service.dart';
import '../../core/models/diary_entry.dart';
import '../../core/network/endpoints.dart';

class DiaryService {
  DiaryService._();

  static Future<List<DiaryEntry>> fetchEntries() async {
    final res = await AuthService.authedGet<Map<String, dynamic>>(
      Endpoints.diaryEntries,
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    final list = data is Map<String, dynamic>
        ? data['data'] as List<dynamic>? ?? const []
        : data is List<dynamic>
            ? data
            : const [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(DiaryEntry.fromJson)
        .toList();
  }

  static Future<DiaryEntry?> fetchToday() async {
    final res = await AuthService.authedGet<Map<String, dynamic>>(
      Endpoints.diaryToday,
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    if (data is! Map<String, dynamic>) return null;
    return DiaryEntry.fromJson(data);
  }

  static Future<DiaryEntry> create({
    required String entryDate,
    String? title,
    String? sky,
    List<String>? feelings,
    String? impact,
    String? gratitude,
    String? bodyHtml,
    File? imageFile,
  }) async {
    if (imageFile != null) {
      final form = FormData.fromMap({
        ..._fields(
          entryDate: entryDate,
          title: title,
          sky: sky,
          feelings: feelings,
          impact: impact,
          gratitude: gratitude,
          bodyHtml: bodyHtml,
          multipart: true,
        ),
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split(RegExp(r'[/\\]')).last,
        ),
      });
      final res = await AuthService.authedPost<Map<String, dynamic>>(
        Endpoints.diaryEntries,
        data: form,
      );
      return _entryFromResponse(res.data);
    }

    final res = await AuthService.authedPost<Map<String, dynamic>>(
      Endpoints.diaryEntries,
      data: _fields(
        entryDate: entryDate,
        title: title,
        sky: sky,
        feelings: feelings,
        impact: impact,
        gratitude: gratitude,
        bodyHtml: bodyHtml,
      ),
    );
    return _entryFromResponse(res.data);
  }

  static Future<DiaryEntry> update({
    required int id,
    String? title,
    String? sky,
    List<String>? feelings,
    String? impact,
    String? gratitude,
    String? bodyHtml,
    File? imageFile,
    bool removeImage = false,
  }) async {
    if (imageFile != null || removeImage) {
      final map = <String, dynamic>{
        ..._fields(
          title: title,
          sky: sky,
          feelings: feelings,
          impact: impact,
          gratitude: gratitude,
          bodyHtml: bodyHtml,
          multipart: true,
        ),
        if (removeImage) 'remove_image': '1',
      };
      if (imageFile != null) {
        map['image'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split(RegExp(r'[/\\]')).last,
        );
      }
      final res = await AuthService.authedPost<Map<String, dynamic>>(
        Endpoints.diaryEntry(id),
        data: FormData.fromMap(map),
      );
      return _entryFromResponse(res.data);
    }

    final res = await AuthService.authedPut<Map<String, dynamic>>(
      Endpoints.diaryEntry(id),
      data: _fields(
        title: title,
        sky: sky,
        feelings: feelings,
        impact: impact,
        gratitude: gratitude,
        bodyHtml: bodyHtml,
      ),
    );
    return _entryFromResponse(res.data);
  }

  static Future<void> delete(int id) async {
    await AuthService.authedDelete<Map<String, dynamic>>(
      Endpoints.diaryEntry(id),
    );
  }

  static DiaryEntry _entryFromResponse(Map<String, dynamic>? root) {
    final data = root?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return DiaryEntry.fromJson(data);
  }

  static Map<String, dynamic> _fields({
    String? entryDate,
    String? title,
    String? sky,
    List<String>? feelings,
    String? impact,
    String? gratitude,
    String? bodyHtml,
    bool multipart = false,
  }) {
    final map = <String, dynamic>{};
    if (entryDate != null) map['entry_date'] = entryDate;
    if (title != null) map['title'] = title.isEmpty ? null : title;
    if (sky != null) map['sky'] = sky.isEmpty ? null : sky;
    if (feelings != null) {
      map['feelings'] = multipart ? jsonEncode(feelings) : feelings;
    }
    if (impact != null) map['impact'] = impact.isEmpty ? null : impact;
    if (gratitude != null) {
      map['gratitude'] = gratitude.isEmpty ? null : gratitude;
    }
    if (bodyHtml != null) {
      map['body_html'] = bodyHtml.isEmpty ? null : bodyHtml;
    }
    return map;
  }
}
