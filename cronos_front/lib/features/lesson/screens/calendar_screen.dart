import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';
import 'package:cronos_front/features/lesson/models/class_lesson.dart'
    show Lesson;
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../app/repository/schedule_repository.dart'
    show ScheduleRepository;
import '../widgets/lesson_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ScheduleRepository _repository = ScheduleRepository();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, DaySchedule> _scheduleMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAndIndexSchedule();
  }

  Future<void> _loadAndIndexSchedule() async {
    try {
      final fullSchedule = await _repository.loadFullSchedule();
      final map = <DateTime, DaySchedule>{};

      for (var day in fullSchedule.schedule) {
        final normalizedDate = DateTime.utc(
          day.date.year,
          day.date.month,
          day.date.day,
        );
        map[normalizedDate] = day;
      }

      if (mounted) {
        setState(() {
          _scheduleMap = map;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar calendário: $e')),
        );
      }
    }
  }

  List<Lesson> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _scheduleMap[normalizedDay]?.lessons ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedEvents = _selectedDay != null
        ? _getEventsForDay(_selectedDay!)
        : [];
    final theme = Theme.of(context);
    final now =
        DateTime.now(); // Pega a hora atual no build para passar pro card

    return Column(
      children: [
        TableCalendar<Lesson>(
          firstDay: DateTime.utc(2026, 1, 1),
          lastDay: DateTime.utc(2026, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            markerSize: 6.0,
            markerDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox();

              final hasExam = events.any((lesson) => lesson.isExam);

              return Positioned(
                bottom: 6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasExam
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 8),
        Expanded(
          child: selectedEvents.isEmpty
              ? const Center(child: Text('Livre. Nenhuma aula neste dia.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: selectedEvents.length,
                  itemBuilder: (context, index) {
                    return LessonCard(
                      lesson: selectedEvents[index],
                      dayDate:
                          _selectedDay ??
                          now, // Passa a data do dia selecionado
                      now: now, // Passa o DateTime.now()
                    );
                  },
                ),
        ),
      ],
    );
  }
}
