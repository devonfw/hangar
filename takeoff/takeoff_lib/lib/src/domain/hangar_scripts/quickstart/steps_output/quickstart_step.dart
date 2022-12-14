// ignore_for_file: public_member_api_docs, sort_constructors_first
class QuickstartStep {
  String goToUrl;
  String? textToCopy;
  String instructions;

  QuickstartStep({
    required this.goToUrl,
    required this.instructions,
    this.textToCopy,
  });

  factory QuickstartStep.fromMap(Map<String, dynamic> map) {
    return QuickstartStep(
        goToUrl: map["goto"]!,
        instructions: map["instructions"]!,
        textToCopy: map["copy"]);
  }
}
