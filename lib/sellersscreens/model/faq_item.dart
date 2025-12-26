
class FaqItem {
  final String question;
  final String answer;
  final String? policyText;

  FaqItem({
    required this.question,
    required this.answer,
    this.policyText,
  });
}
