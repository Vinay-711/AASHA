abstract class CacheManager {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearCache();
}
