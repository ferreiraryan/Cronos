import 'package:cronos_front/app/repository/schedule_repository.dart';
import 'package:cronos_front/app/repository/study_repository.dart';
import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';
import 'package:cronos_front/features/lesson/models/class_lesson.dart';
import 'package:cronos_front/features/lesson/models/class_study_task.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/lesson_card.dart';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/lesson_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ScheduleRepository _scheduleRepo = ScheduleRepository();
  final StudyRepository _studyRepo = StudyRepository();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Map<DateTime, DaySchedule> get _scheduleMap {
    final map = <DateTime, DaySchedule>{};
    try {
      for (var day in _scheduleRepo.schedule.schedule) {
        final normalizedDate = DateTime.utc(
          day.date.year,
          day.date.month,
          day.date.day,
        );
        map[normalizedDate] = day;
      }
    } catch (_) {}
    return map;
  }

  // Faz o cruzamento (merge) das aulas e tarefas para o dia específico
  List<dynamic> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    final lessons = _scheduleMap[normalizedDay]?.lessons ?? [];

    final tasks = _studyRepo.plan.tasks.where((t) {
      if (t.isDaily) return true;
      if (t.date != null) {
        return t.date!.year == day.year &&
            t.date!.month == day.month &&
            t.date!.day == day.day;
      }
      return false;
    }).toList();

    return [...lessons, ...tasks];
  }

  @override
  Widget build(BuildContext context) {
    // Agora o calendário escuta AMBOS os repositórios para ser reativo
    return AnimatedBuilder(
      animation: Listenable.merge([_scheduleRepo, _studyRepo]),
      builder: (context, _) {
        final selectedEvents = _selectedDay != null
            ? _getEventsForDay(_selectedDay!)
            : [];
        final theme = Theme.of(context);
        final now = DateTime.now();

        return Column(
          children: [
            TableCalendar<dynamic>(
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
                // Marcadores visuais multi-tipos
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox();

                  bool hasExam = events.any((e) => e is Lesson && e.isExam);
                  bool hasLesson = events.any((e) => e is Lesson && !e.isExam);
                  bool hasTask = events.any((e) => e is StudyTask);

                  List<Widget> markers = [];

                  if (hasExam) {
                    markers.add(
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    );
                  }
                  if (hasLesson) {
                    markers.add(
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  }
                  if (hasTask) {
                    markers.add(
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.tealAccent,
                        ),
                      ),
                    );
                  }

                  return Positioned(
                    bottom: 6,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: markers,
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: selectedEvents.isEmpty
                  ? const Center(
                      child: Text(
                        'Livre. Nenhum evento ou aula neste dia.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = selectedEvents[index];

                        if (event is Lesson) {
                          return LessonCard(
                            lesson: event,
                            dayDate: _selectedDay ?? now,
                            now: now,
                          );
                        } else if (event is StudyTask) {
                          // Reaproveita a UI de tarefas aqui (com swipe to delete e check)
                          List<String> meta = [];
                          if (event.isDaily) meta.add('Diário');
                          if (event.time != null) meta.add(event.time!);
                          final metaString = meta.join(' • ');

                          return Dismissible(
                            key: Key('cal_${event.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) => _studyRepo.removeTask(event.id),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: CheckboxListTile(
                                title: Text(
                                  event.title,
                                  style: TextStyle(
                                    decoration: event.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (event.subjectName != null)
                                      Text(
                                        event.subjectName!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    if (metaString.isNotEmpty)
                                      Text(
                                        metaString,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                value: event.isDone,
                                onChanged: (_) =>
                                    _studyRepo.toggleTask(event.id),
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
