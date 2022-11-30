class CloudRunException implements Exception {
  final String message;
  const CloudRunException(this.message);
  @override
  String toString() {
    return "CloudRunException: $message";
  }
}
