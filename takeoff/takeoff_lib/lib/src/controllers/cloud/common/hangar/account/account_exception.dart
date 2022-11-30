class AccountException implements Exception {
  final String message;
  const AccountException(this.message);
  @override
  String toString() {
    return "AccountException: $message";
  }
}
