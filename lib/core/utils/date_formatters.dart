import 'package:intl/intl.dart';

/// Parses API ISO / SQL datetime strings and formats for display.
DateTime? parseApiDate(String? raw) {
  if (raw == null) return null;
  final value = raw.trim();
  if (value.isEmpty) return null;
  return DateTime.tryParse(value) ??
      DateTime.tryParse(value.replaceFirst(' ', 'T'));
}

/// e.g. `04 Sep 2025` in the device local timezone.
String formatApiDate(String? raw, {String pattern = 'dd MMM yyyy'}) {
  final parsed = parseApiDate(raw);
  if (parsed == null) return (raw ?? '').trim();
  return DateFormat(pattern).format(parsed.toLocal());
}

/// e.g. `04 Sep 2025, 12:00 AM`
String formatApiDateTime(String? raw) {
  return formatApiDate(raw, pattern: 'dd MMM yyyy, h:mm a');
}
