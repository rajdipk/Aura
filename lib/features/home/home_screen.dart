import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/services/events_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/custom_page_route.dart';
import '../models/events.dart';
import 'chat_screen.dart';

final calendarStateProvider =
    StateNotifierProvider<CalendarStateNotifier, CalendarState>((ref) {
  return CalendarStateNotifier();
});

class CalendarState {
  final DateTime focusedDay;
  final DateTime? selectedDay;

  CalendarState({required this.focusedDay, this.selectedDay});
}

class CalendarStateNotifier extends StateNotifier<CalendarState> {
  CalendarStateNotifier() : super(CalendarState(focusedDay: DateTime.now()));

  void updateSelectedDay(DateTime selectedDay, DateTime focusedDay) {
    state = CalendarState(focusedDay: focusedDay, selectedDay: selectedDay);
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final isDark = theme.brightness == Brightness.dark;
    final events = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aura'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 5,
        padding: const EdgeInsets.all(16),
        childAspectRatio: 1.0,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildFeatureCard(
            context,
            'Chat',
            Icons.chat_bubble_outline,
            () => Navigator.push(
                context, CustomPageRoute(child: const ChatScreen())),
          ),
          _buildFeatureCard(
            context,
            'Voice Commands',
            Icons.mic_none,
            () {/* TODO: Implement voice command screen */},
          ),
          _buildCalendarCard(context, ref, events), // Updated calendar card
          _buildFeatureCard(
            context,
            'Settings',
            Icons.settings_outlined,
            () {/* TODO: Implement settings screen */},
          ),
          _buildFeatureCard(
            context,
            'Help',
            Icons.help_outline,
            () {/* TODO: Implement help screen */},
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(title, style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(
      BuildContext context, WidgetRef ref, List<Event> events) {
    final calendarState = ref.watch(calendarStateProvider);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to full calendar view
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Calendar',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: calendarState.focusedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(calendarState.selectedDay, day),
                calendarFormat: CalendarFormat.week,
                headerVisible: false,
                daysOfWeekVisible: false,
                sixWeekMonthsEnforced: true,
                rowHeight: 30,
                onDaySelected: (selectedDay, focusedDay) {
                  ref
                      .read(calendarStateProvider.notifier)
                      .updateSelectedDay(selectedDay, focusedDay);
                  _showEventDialog(context, ref, selectedDay);
                },
                eventLoader: (day) =>
                    ref.read(eventsProvider.notifier).getEventsForDay(day),
                calendarStyle: CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDialog(
      BuildContext context, WidgetRef ref, DateTime selectedDay) {
    final events =
        ref.read(eventsProvider.notifier).getEventsForDay(selectedDay);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Events on ${selectedDay.toString().split(' ')[0]}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...events.map((event) => ListTile(
                    title: Text(event.title),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ref.read(eventsProvider.notifier).removeEvent(event);
                        Navigator.of(context).pop();
                      },
                    ),
                  )),
              TextButton(
                child: const Text('Add Event'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showAddEventDialog(context, ref, selectedDay);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddEventDialog(
      BuildContext context, WidgetRef ref, DateTime selectedDay) {
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Event'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Event Title'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  ref.read(eventsProvider.notifier).addEvent(
                        Event(titleController.text, selectedDay),
                      );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
