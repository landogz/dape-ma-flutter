class CareToolkitQuestion {
  const CareToolkitQuestion({
    required this.id,
    required this.toolkitType,
    required this.answerType,
    required this.question,
    required this.options,
    required this.sortOrder,
  });

  final int id;
  final String toolkitType;
  final String answerType;
  final String question;
  final List<String> options;
  final int sortOrder;

  factory CareToolkitQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    return CareToolkitQuestion(
      id: (json['id'] as num?)?.toInt() ?? 0,
      toolkitType: (json['toolkit_type'] ?? '').toString(),
      answerType: (json['answer_type'] ?? 'likert5').toString(),
      question: (json['question'] ?? '').toString(),
      options: rawOptions is List
          ? rawOptions.map((e) => e.toString()).toList()
          : const [],
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
