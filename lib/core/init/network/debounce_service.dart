import 'dart:async';

import 'package:flutter/material.dart';

class DebounceService {
  static final DebounceService _instance = DebounceService._internal();
  factory DebounceService() => _instance;
  DebounceService._internal();

  final Map<String, Timer> _timers = {};
  final Map<String, DateTime> _lastClickTimes = {};

  // Default debounce time is 500ms
  static const Duration defaultDebounceTime = Duration(milliseconds: 3000);

  /// Executes function only if it hasn't been called within the debounce time
  bool canExecute(String key, {Duration? debounceTime}) {
    final duration = debounceTime ?? defaultDebounceTime;
    final now = DateTime.now();

    if (_lastClickTimes.containsKey(key)) {
      final lastClickTime = _lastClickTimes[key]!;
      if (now.difference(lastClickTime) < duration) {
        return false;
      }
    }

    _lastClickTimes[key] = now;

    // Cancel existing timer if any
    _timers[key]?.cancel();

    // Set a timer to clear the entry after debounce time
    _timers[key] = Timer(duration, () {
      _lastClickTimes.remove(key);
      _timers.remove(key);
    });

    return true;
  }

  /// Execute function with debounce protection
  void execute(
    String key,
    VoidCallback function, {
    Duration? debounceTime,
  }) {
    if (canExecute(key, debounceTime: debounceTime)) {
      function();
    }
  }

  /// Clear all debounce timers
  void clear() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _lastClickTimes.clear();
  }

  /// Clear specific key
  void clearKey(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
    _lastClickTimes.remove(key);
  }
}
