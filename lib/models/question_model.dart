enum QuestionType { multipleChoice, number, date }

class QuestionModel {
  final String question;
  final List<String>? options;
  final QuestionType type;

  QuestionModel({
    required this.question,
    this.options,
    this.type = QuestionType.multipleChoice,
  });
}
