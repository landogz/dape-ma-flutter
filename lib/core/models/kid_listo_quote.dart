/// Quote body without a repeated "Kid Listo says:" / "Sabi ni Kid Listo:" prefix.
String kidListoQuoteBody(String? raw) {
  var text = (raw ?? '').trim();
  if (text.isEmpty) return '';

  const prefixes = [
    'Kid Listo says:',
    'Kid Listo says',
    'Kid Listo Says:',
    'Kid Listo Says',
    'Sabi ni Kid Listo:',
    'Sabi ni Kid Listo',
  ];
  final lower = text.toLowerCase();
  for (final prefix in prefixes) {
    if (lower.startsWith(prefix.toLowerCase())) {
      text = text.substring(prefix.length).trim();
      break;
    }
  }
  if (text.startsWith(':')) {
    text = text.substring(1).trim();
  }
  return text;
}

class KidListoQuote {
  const KidListoQuote({
    required this.id,
    required this.brand,
    required this.brandTagline,
    required this.message,
    this.attribution,
    required this.locale,
  });

  final int id;
  final String brand;
  final String brandTagline;
  final String message;
  final String? attribution;
  final String locale;

  factory KidListoQuote.fromJson(Map<String, dynamic> json) {
    return KidListoQuote(
      id: (json['id'] as num?)?.toInt() ?? 0,
      brand: (json['brand'] ?? 'Kid Listo Says') as String,
      brandTagline: (json['brand_tagline'] ?? '') as String,
      message: (json['message'] ?? json['kid_listo_message'] ?? '') as String,
      attribution: json['attribution'] as String?,
      locale: (json['locale'] ?? 'en') as String,
    );
  }
}
