class ProfileAbout {
  static const maxLength = 70;

  static String clamp(String? value) {
    final text = value?.trim() ?? '';
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength).trimRight();
  }
}
