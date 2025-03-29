/// Abstract base service that defines the standard operations
abstract class BaseService<T> {
  /// Fetch all items of type T
  Future<List<T>> fetchAll();

  /// Fetch a single item by ID
  Future<T?> fetchById(String id);

  /// Save a new item
  Future<void> save(T item);

  /// Update an existing item
  Future<void> update(T item);

  /// Delete an item by ID
  Future<void> delete(String id);
}
