import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../features/models/events.dart';

final eventsProvider = StateNotifierProvider<EventNotifier, List<Event>>((ref) {
  return EventNotifier();
});

class EventNotifier extends StateNotifier<List<Event>> {
  EventNotifier() : super([]);

  void addEvent(Event event) {
    state = [...state, event];
  }

  void removeEvent(Event event) {
    state = state.where((e) => e != event).toList();
  }

  List<Event> getEventsForDay(DateTime day) {
    return state.where((event) => isSameDay(event.date, day)).toList();
  }
}