import 'dart:async';

import 'package:vilsa/core/init/event/event_type_enum.dart';

/// Event veri yapısı
class AppEvent {
  final EventType type;
  final dynamic data;

  AppEvent(this.type, {this.data});
}

/// EventBus sınıfı - Singleton tasarım deseni ile
class EventBus {
  static final EventBus _instance = EventBus._internal();

  /// Event stream controller
  final StreamController<AppEvent> _eventController = StreamController<AppEvent>.broadcast();

  EventBus._internal();

  /// Singleton instance
  static EventBus get instance => _instance;

  /// Event stream'ine erişim
  Stream<AppEvent> get eventStream => _eventController.stream;

  /// Event yayınlama metodu
  void fireEvent(EventType type, {dynamic data}) {
    print("🔔 EVENT FIRED: $type, Data: $data");
    _eventController.add(AppEvent(type, data: data));
  }

  /// Belirli bir event türünü dinlemek için
  Stream<AppEvent> on(EventType type) {
    return eventStream.where((event) => event.type == type);
  }

  /// EventBus'ı kapatma
  void dispose() {
    _eventController.close();
  }
}
