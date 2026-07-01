class RehabCenter {
  final int id;
  final String name;
  final String address;
  final String region;
  final String province;
  final String contact;
  final String? website;

  RehabCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.region,
    required this.province,
    required this.contact,
    this.website,
  });

  factory RehabCenter.fromJson(Map<String, dynamic> json) {
    return RehabCenter(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      region: json['region'] as String? ?? '',
      province: json['province'] as String? ?? '',
      contact: (json['contact'] ?? json['contact_number']) as String? ?? '',
      website: json['website'] as String?,
    );
  }
}

