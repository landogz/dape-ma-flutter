class CareSupportItem {
  const CareSupportItem({
    required this.id,
    required this.category,
    required this.title,
    this.role,
    this.description,
    this.meta,
    this.phone,
    this.webUrl,
    this.logoUrl,
    this.logoInitial,
    this.iconKey,
    this.body = const [],
    this.isEmergency = false,
    this.sortOrder = 0,
  });

  final int id;
  final String category;
  final String title;
  final String? role;
  final String? description;
  final String? meta;
  final String? phone;
  final String? webUrl;
  final String? logoUrl;
  final String? logoInitial;
  final String? iconKey;
  final List<String> body;
  final bool isEmergency;
  final int sortOrder;

  factory CareSupportItem.fromJson(Map<String, dynamic> json) {
    final rawBody = json['body'];
    return CareSupportItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      category: (json['category'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      role: json['role']?.toString(),
      description: json['description']?.toString(),
      meta: json['meta']?.toString(),
      phone: json['phone']?.toString(),
      webUrl: json['web_url']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      logoInitial: json['logo_initial']?.toString(),
      iconKey: json['icon_key']?.toString(),
      body: rawBody is List
          ? rawBody.map((e) => e.toString()).toList()
          : const [],
      isEmergency: json['is_emergency'] == true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
