class UnsupportedPlatformException implements Exception {
  final String message;
  const UnsupportedPlatformException(this.message);
  @override
  String toString() {
    return "UnsupportedException: $message";
  }
}
