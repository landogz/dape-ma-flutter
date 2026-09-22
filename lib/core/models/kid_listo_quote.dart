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
