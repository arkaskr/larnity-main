import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/datasource/event_datasource.dart';
import 'package:larnity/src/features/group/data/models/event_model.dart';

final eventProvider = ChangeNotifierProvider<EventProvider>((ref) {
  return EventProvider(ref.watch(eventDataSourceProvider));
});

class EventProvider extends ChangeNotifier {
  final EventDataSource _eventDataSource;

  EventProvider(this._eventDataSource);

  List<EventModel> _events = [];
  List<EventModel> get events => _events;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Create Event
  Future<bool> createEvent(EventModel event) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _eventDataSource.createEvent(event: event);

      return result.fold(
        (failure) {
          Log.error("Create Event Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (createdEvent) async {
          Log.info("Event created successfully: ${createdEvent.id}");
          await fetchEvents(event.groupId);
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Fetch Events by Group
  Future<void> fetchEvents(String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _eventDataSource.getEventsByGroup(groupId: groupId);

      result.fold(
        (failure) {
          Log.error("Fetch Events Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
        },
        (events) {
          _events = events;
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Update Event
  Future<bool> updateEvent(EventModel event) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _eventDataSource.updateEvent(event: event);

      return result.fold(
        (failure) {
          Log.error("Update Event Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (updatedEvent) async {
          Log.info("Event updated successfully: ${updatedEvent.id}");
          await fetchEvents(event.groupId);
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete Event
  Future<bool> deleteEvent(String eventId, String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _eventDataSource.deleteEvent(id: eventId);

      return result.fold(
        (failure) {
          Log.error("Delete Event Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (_) async {
          Log.info("Event deleted successfully");
          await fetchEvents(groupId);
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
