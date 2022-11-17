/// Exception launched when a pipeline fails to be created.
class CreatePipelineException implements Exception {
  final String message;
  const CreatePipelineException(this.message);
  @override
  String toString() {
    return "CreatePipelineException: $message";
  }
}
