abstract class CacheRepository {
  /// Saves the Google Cloud email in the cache DB
  Future<bool> saveGoogleEmail(String email);

  /// Retrieves the Google Cloud email from the cache DB
  Future<String> getGoogleEmail();

  /// Stores a new Google Cloud Project ID
  Future<bool> saveGoogleProjectId(String projectId);

  /// Returns all the Google Cloud Project IDs from the logged account
  Future<List<String>> getGoogleProjectIds();

  /// Returns all the Google Cloud Project IDs from the logged account
  Future<bool> removeGoogleProject(String projectId);
}
