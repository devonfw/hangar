class GCloudAccountException implements Exception {
  final String message;
  const GCloudAccountException(this.message);
  @override
  String toString() {
    return "GCloudAccountException: $message";
  }
}
