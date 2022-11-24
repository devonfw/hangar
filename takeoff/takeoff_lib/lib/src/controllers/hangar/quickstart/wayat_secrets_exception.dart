class WayatSecretsException implements Exception {
  final String message;
  const WayatSecretsException(this.message);
  @override
  String toString() {
    return "WayatSecretsException: $message";
  }
}
