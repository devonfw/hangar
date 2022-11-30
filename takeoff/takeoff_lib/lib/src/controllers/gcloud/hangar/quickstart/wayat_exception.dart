class WayatException implements Exception {
  final String message;
  const WayatException(this.message);
  @override
  String toString() {
    return "WayatException: $message";
  }
}
