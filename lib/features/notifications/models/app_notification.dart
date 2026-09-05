class AppNotification {
  final int id;
  final String type;
  final String title;
  final String? body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.data = const {},
    this.readAt,
    this.createdAt,
  });

  bool get isUnread => readAt == null;

  int? get postId {
    final value = data['post_id'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return AppNotification(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      data: rawData is Map<String, dynamic>
          ? rawData
          : <String, dynamic>{},
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
