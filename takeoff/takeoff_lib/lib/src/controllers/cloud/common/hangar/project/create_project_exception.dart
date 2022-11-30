/// Exception launched when something fails in [GoogleCloudController.createProject].
class CreateProjectException implements Exception {
  final String message;
  const CreateProjectException(this.message);
  @override
  String toString() {
    return "CreateProjectException: $message";
  }
}
