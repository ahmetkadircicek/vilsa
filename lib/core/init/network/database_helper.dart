abstract class DatabaseServiceInterface {
  Future<String?> push(String path, Map<String, dynamic> data);
  Future<void> update(String path, String key, Map<String, dynamic> data);
  Future<void> delete(String path, String key);
  Future<Map<String, dynamic>> getAll(String path);
  Future<String?> findKey(String path, String fieldName, dynamic fieldValue);
  Future<List<String>> findKeys(
      String path, String fieldName, dynamic fieldValue);
}
