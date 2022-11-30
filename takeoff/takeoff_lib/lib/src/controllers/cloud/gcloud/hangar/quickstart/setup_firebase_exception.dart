class SetUpFirebaseException implements Exception {
  final String message;
  const SetUpFirebaseException(this.message);
  @override
  String toString() {
    return "SetUpFirebaseException: $message";
  }
}
