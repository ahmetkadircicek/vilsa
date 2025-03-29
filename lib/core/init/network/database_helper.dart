import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Helper class for Firebase Realtime Database operations
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  final _database = FirebaseDatabase.instance.ref();

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  /// Save data to a specific path with auto-generated key
  Future<String?> push(String path, Map<String, dynamic> data) async {
    try {
      final newRef = _database.child(path).push();
      final firebaseKey = newRef.key;

      if (firebaseKey != null) {
        await newRef.set(data);
        debugPrint("🚀 Data saved to $path with key: $firebaseKey");
      }

      return firebaseKey;
    } catch (e) {
      debugPrint("🚨 Error saving data to $path: $e");
      throw Exception("Failed to save data: $e");
    }
  }

  /// Update data at a specific path and key
  Future<void> update(String path, String key, Map<String, dynamic> data) async {
    try {
      await _database.child(path).child(key).update(data);
      debugPrint("🚀 Data updated at $path/$key");
    } catch (e) {
      debugPrint("🚨 Error updating data at $path/$key: $e");
      throw Exception("Failed to update data: $e");
    }
  }

  /// Delete data at a specific path and key
  Future<void> delete(String path, String key) async {
    try {
      await _database.child(path).child(key).remove();
      debugPrint("🚀 Data removed from $path/$key");
    } catch (e) {
      debugPrint("🚨 Error removing data from $path/$key: $e");
      throw Exception("Failed to delete data: $e");
    }
  }

  /// Get all data from a specific path
  Future<Map<String, dynamic>> getAll(String path) async {
    try {
      final snapshot = await _database.child(path).get();
      if (snapshot.exists && snapshot.value != null) {
        final rawData = snapshot.value as Map<Object?, Object?>;
        final result = <String, dynamic>{};

        rawData.forEach((key, value) {
          if (key != null) {
            result[key.toString()] = value;
          }
        });

        return result;
      }
    } catch (e) {
      debugPrint("🚨 Error fetching data from $path: $e");
      throw Exception("Failed to fetch data: $e");
    }
    return {};
  }

  /// Find key in a path where a field matches a value
  Future<String?> findKey(String path, String fieldName, dynamic fieldValue) async {
    try {
      final data = await getAll(path);

      for (var entry in data.entries) {
        final value = entry.value;
        if (value is Map && value[fieldName] == fieldValue) {
          return entry.key;
        }
      }
    } catch (e) {
      debugPrint("🚨 Error finding key in $path where $fieldName=$fieldValue: $e");
    }
    return null;
  }

  /// Find all keys in a path where a field matches a value
  Future<List<String>> findKeys(String path, String fieldName, dynamic fieldValue) async {
    final List<String> keys = [];

    try {
      final data = await getAll(path);

      for (var entry in data.entries) {
        final value = entry.value;
        if (value is Map && value[fieldName] == fieldValue) {
          keys.add(entry.key);
        }
      }
    } catch (e) {
      debugPrint("🚨 Error finding keys in $path where $fieldName=$fieldValue: $e");
    }

    return keys;
  }
}
