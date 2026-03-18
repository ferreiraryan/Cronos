import 'package:cronos_front/features/lesson/models/class_lesson.dart';
import 'package:cronos_front/features/lesson/widgets/edit_modal.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final DateTime dayDate;
  final DateTime now;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.dayDate,
    required this.now,
  });

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(
      dayDate.year,
      dayDate.month,
      dayDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final startTime = _parseTime(lesson.timeStart);
    final endTime = _parseTime(lesson.timeEnd);

    bool isPast = now.isAfter(endTime);
    bool isCurrent = now.isAfter(startTime) && now.isBefore(endTime);
    bool isCancelled = lesson.metadata.isCancelled;

    double progress = 0.0;
    if (isPast) {
      progress = 1.0;
    } else if (isCurrent && !isCancelled) {
      final totalMinutes = endTime.difference(startTime).inMinutes;
      final elapsedMinutes = now.difference(startTime).inMinutes;
      progress = elapsedMinutes / totalMinutes;
    }

    final double cardOpacity = (isPast || isCancelled) ? 0.5 : 1.0;

    return Opacity(
      opacity: cardOpacity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isCancelled
              ? BorderSide(
                  color: theme.colorScheme.error.withOpacity(0.5),
                  width: 1.5,
                )
              : isCurrent
              ? BorderSide(color: theme.colorScheme.primary, width: 2.0)
              : lesson.isExam
              ? BorderSide(color: Colors.orangeAccent, width: 1.5)
              : BorderSide.none,
        ),
        child: Column(
          children: [
            ExpansionTile(
              shape: const Border(),
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lesson.timeStart,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    lesson.timeEnd,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              title: Text(
                lesson.subjectName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: isCancelled ? TextDecoration.lineThrough : null,
                  color: isCancelled
                      ? theme.colorScheme.error
                      : (lesson.isExam ? Colors.orangeAccent : null),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.location, style: const TextStyle(fontSize: 13)),
                  if (isCancelled)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Cancelada: ${lesson.metadata.cancelReason ?? "Sem motivo informado"}',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: isCancelled
                  ? Icon(Icons.cancel, color: theme.colorScheme.error)
                  : lesson.isExam
                  ? const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orangeAccent,
                    )
                  : (isCurrent
                        ? Icon(
                            Icons.play_circle_fill,
                            color: theme.colorScheme.primary,
                          )
                        : null),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.subject,
                        'Tópico',
                        lesson.topic ?? 'Aula normal (Sem tópico especificado)',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.short_text,
                        'Resumo',
                        lesson.summary ?? 'Sem resumo detalhado',
                      ),

                      if (lesson.references.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(Icons.menu_book, size: 20, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Referências:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...lesson.references.map(
                          (ref) => Padding(
                            padding: const EdgeInsets.only(
                              left: 28.0,
                              bottom: 4.0,
                            ),
                            child: Text(
                              '• $ref',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () =>
                              LessonEditModal.show(context, lesson, dayDate),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Editar Aula'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((isCurrent || isPast) && !isCancelled)
              LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.transparent,
                color: isPast
                    ? Colors.grey.withOpacity(0.5)
                    : theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(content, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
