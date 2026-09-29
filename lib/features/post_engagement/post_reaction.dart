enum PostReactionType {
  like,
  love,
  haha,
  sad,
  angry,
}

extension PostReactionTypeX on PostReactionType {
  String get apiValue => name;

  String get emoji {
    switch (this) {
      case PostReactionType.like:
        return '👍';
      case PostReactionType.love:
        return '❤️';
      case PostReactionType.haha:
        return '😆';
      case PostReactionType.sad:
        return '😢';
      case PostReactionType.angry:
        return '😡';
    }
  }

  String get label {
    switch (this) {
      case PostReactionType.like:
        return 'Like';
      case PostReactionType.love:
        return 'Love';
      case PostReactionType.haha:
        return 'Haha';
      case PostReactionType.sad:
        return 'Sad';
      case PostReactionType.angry:
        return 'Angry';
    }
  }
}

PostReactionType? postReactionFromApi(String? value) {
  if (value == null || value.isEmpty) return null;
  for (final type in PostReactionType.values) {
    if (type.apiValue == value) return type;
  }
  return null;
}

Map<PostReactionType, int> parseReactionCounts(dynamic raw) {
  final counts = <PostReactionType, int>{
    for (final type in PostReactionType.values) type: 0,
  };

  if (raw is! Map) return counts;

  for (final type in PostReactionType.values) {
    final value = raw[type.apiValue];
    if (value is num) {
      counts[type] = value.toInt();
    } else if (value != null) {
      counts[type] = int.tryParse(value.toString()) ?? 0;
    }
  }

  return counts;
}

List<PostReactionType> topReactionTypes(
  Map<PostReactionType, int> counts, {
  int limit = 3,
}) {
  final entries = counts.entries.where((e) => e.value > 0).toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries.take(limit).map((e) => e.key).toList();
}
