//home_screen.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/services/events_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/custom_page_route.dart';
import '../models/events.dart';
import 'chat_screen.dart';

// Calendar State Management
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

class AnimatedTitle extends StatefulWidget {
  const AnimatedTitle({Key? key}) : super(key: key);

  @override
  State<AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<AnimatedTitle> {
  bool _showFullName = false;
  Timer? _timer;

  void _toggleTitle() {
    setState(() {
      _showFullName = true;
    });

    // Reset after 3 seconds
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showFullName = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleTitle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Text(
          _showFullName ? 'Advanced Universal Responsive Assistant' : 'Aura',
          key: ValueKey(_showFullName),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final isDark = theme.brightness == Brightness.dark;
    final events = ref.watch(eventsProvider); // Use the events variable
    final calendarState = ref.watch(calendarStateProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome,
                      size: 20, color: Theme.of(context).colorScheme.onPrimary),
                  const SizedBox(width: 8),
                  const AnimatedTitle(), // Replace the Text widget with AnimatedTitle
                ],
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                  ),
                  // Decorative overlay pattern
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GridPainter(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                    color: Theme.of(context).colorScheme.onPrimary),
                onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              ),
            ],
          ),

          // Calendar Section
          // Calendar Section with enhanced styling
          SliverToBoxAdapter(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Calendar',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  TableCalendar(
                    firstDay: DateTime.utc(2023, 1, 1),
                    lastDay: DateTime.utc(2025, 12, 31),
                    focusedDay: calendarState.focusedDay,
                    selectedDayPredicate: (day) =>
                        isSameDay(calendarState.selectedDay, day),
                    calendarFormat: CalendarFormat.week,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
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
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Features Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              delegate: SliverChildListDelegate([
                _buildFeatureCard(
                  context,
                  'Chat',
                  Icons.chat_bubble_outline,
                  'Start a conversation',
                  'Connect with Aura',
                  () => Navigator.push(
                    context,
                    CustomPageRoute(child: const ChatScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Voice Commands',
                  Icons.mic_none,
                  'Control with voice',
                  'Voice Commands Screen',
                  () {/* TODO: Implement voice command screen */},
                ),
                _buildFeatureCard(
                  context,
                  'Settings',
                  Icons.settings_outlined,
                  'Customize your app',
                  'Settings Screen',
                  () {/* TODO: Implement settings screen */},
                ),
                _buildFeatureCard(
                  context,
                  'Help',
                  Icons.help_outline,
                  'Get assistance',
                  'Help Screen',
                  () {/* TODO: Implement help screen */},
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDialog(
      BuildContext context, WidgetRef ref, DateTime selectedDay) {
    final events =
        ref.read(eventsProvider.notifier).getEventsForDay(selectedDay);

    Navigator.of(context).push(
      DialogRoute<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Events on ${selectedDay.toString().split(' ')[0]}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (events.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No events for this day'),
                  ),
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
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Event'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Add a small delay before showing the add dialog
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _showAddEventDialog(context, ref, selectedDay);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEventDialog(
      BuildContext context, WidgetRef ref, DateTime selectedDay) {
    final TextEditingController titleController = TextEditingController();

    // Add a small delay before showing the dialog to ensure the input element is properly focused
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).push(
        DialogRoute<void>(
          context: context,
          builder: (BuildContext context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Add Event'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Event Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    autofocus: true, // Ensure the text field is properly focused
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
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
            ),
          ),
        ),
      );
    });
  }
}

// Custom Grid Painter
class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const double step = 20;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
