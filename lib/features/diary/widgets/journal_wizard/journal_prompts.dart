/// Local rotating daily reflection prompts (date-seeded).
class JournalPrompts {
  JournalPrompts._();

  static const List<String> _en = [
    'What is one small win you want to protect today?',
    'Who or what helped you stay grounded this week?',
    'What feeling showed up most for you today, and why?',
    'If today had a weather, what sky would it be — and what does that mean?',
    'What is one craving or urge you noticed without acting on it?',
    'How did your circle (or quiet time alone) shape your day?',
    'What would kindness to yourself look like tonight?',
    'What are you learning about your triggers lately?',
    'Name one thing you are grateful for in this moment.',
    'What boundary do you want to honor tomorrow?',
  ];

  static const List<String> _tl = [
    'Ano ang isang maliit na tagumpay na gusto mong protektahan ngayon?',
    'Sino o ano ang tumulong sa iyong manatiling matatag ngayong linggo?',
    'Anong damdamin ang pinakamadalas na dumating ngayon, at bakit?',
    'Kung may panahon ang araw na ito, anong langit iyon — at ano ang ibig sabihin?',
    'Anong craving o urge ang napansin mo nang hindi pinagsunod-sunod?',
    'Paano humubog ang iyong bilog (o tahimik na oras) sa araw mo?',
    'Ano ang anyo ng kabaitan sa sarili ngayong gabi?',
    'Ano ang natututuhan mo tungkol sa iyong mga trigger nitong mga araw?',
    'Pangalanan ang isang bagay na pinapasalamatan mo sa sandaling ito.',
    'Anong hangganan ang gusto mong igalang bukas?',
  ];

  static String forDate(DateTime date, {required bool isTagalog}) {
    final dayOfYear = date.difference(DateTime(date.year)).inDays;
    final list = isTagalog ? _tl : _en;
    return list[dayOfYear % list.length];
  }
}
