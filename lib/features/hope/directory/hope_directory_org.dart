class HopeDirectoryOrg {
  final int id;
  final String name;
  final String? description;
  final String category;
  final String? address;
  final String? phone;
  final String? email;
  final String? logoUrl;

  const HopeDirectoryOrg({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.address,
    this.phone,
    this.email,
    this.logoUrl,
  });

  factory HopeDirectoryOrg.fromJson(Map<String, dynamic> json) {
    return HopeDirectoryOrg(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      category: (json['category'] ?? '') as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }
}
