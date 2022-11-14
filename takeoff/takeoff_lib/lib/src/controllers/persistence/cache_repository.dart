abstract class CacheRepository {
  /// Saves the Google Cloud email in the cache DB
  Future<bool> saveGoogleEmail(String email);

  /// Retrieves the Google Cloud email from the cache DB
  Future<String> getGoogleEmail();
}
