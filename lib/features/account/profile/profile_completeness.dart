/// Identity fields a user can finish on Profile / Edit Profile.
///
/// Activity and badges are not part of this score so a new account can
/// reach 100% before using the rest of the app.
class ProfileCompleteness {
  ProfileCompleteness._();

  static const nameWeight = 0.40;
  static const photoWeight = 0.60;

  static double score({
    required String name,
    String? photoUrl,
    bool hasLocalPhoto = false,
  }) {
    var value = 0.0;
    if (name.trim().isNotEmpty) {
      value += nameWeight;
    }
    if (hasLocalPhoto || (photoUrl != null && photoUrl.trim().isNotEmpty)) {
      value += photoWeight;
    }
    return value.clamp(0.0, 1.0);
  }

  static bool isComplete({
    required String name,
    String? photoUrl,
    bool hasLocalPhoto = false,
  }) {
    return score(
          name: name,
          photoUrl: photoUrl,
          hasLocalPhoto: hasLocalPhoto,
        ) >=
        1.0;
  }

  static double scoreFromUser(Map<String, dynamic> user) {
    final name = (user['name'] ?? '').toString().trim();
    return score(
      name: name,
      photoUrl: user['profile_image_url']?.toString(),
    );
  }

  static bool isCompleteFromUser(Map<String, dynamic> user) {
    return scoreFromUser(user) >= 1.0;
  }
}
