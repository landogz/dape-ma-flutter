class JournalEntryFilters {
  const JournalEntryFilters({
    this.period = 'all',
    this.sky,
    this.feeling,
    this.search = '',
  });

  final String period;
  final String? sky;
  final String? feeling;
  final String search;

  static const periods = ['all', 'today', 'week', 'month'];

  bool get hasExtras {
    return (sky != null && sky!.isNotEmpty) ||
        (feeling != null && feeling!.isNotEmpty) ||
        search.trim().isNotEmpty;
  }

  bool get isNarrowed => period != 'all' || hasExtras;

  int get extraCount {
    var count = 0;
    if (sky != null && sky!.isNotEmpty) count++;
    if (feeling != null && feeling!.isNotEmpty) count++;
    if (search.trim().isNotEmpty) count++;
    return count;
  }

  JournalEntryFilters copyWith({
    String? period,
    String? sky,
    bool clearSky = false,
    String? feeling,
    bool clearFeeling = false,
    String? search,
  }) {
    return JournalEntryFilters(
      period: period ?? this.period,
      sky: clearSky ? null : (sky ?? this.sky),
      feeling: clearFeeling ? null : (feeling ?? this.feeling),
      search: search ?? this.search,
    );
  }

  JournalEntryFilters cleared() => const JournalEntryFilters();

  Map<String, dynamic> toQuery({int perPage = 50}) {
    return {
      'per_page': perPage,
      if (period != 'all') 'period': period,
      if (sky != null && sky!.isNotEmpty) 'sky': sky,
      if (feeling != null && feeling!.isNotEmpty) 'feeling': feeling,
      if (search.trim().isNotEmpty) 'search': search.trim(),
    };
  }
}
