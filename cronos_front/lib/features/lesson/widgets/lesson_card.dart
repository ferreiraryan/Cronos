import 'package:cronos_front/features/lesson/models/class_lesson.dart';
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

    double progress = 0.0;
    if (isPast) {
      progress = 1.0;
    } else if (isCurrent) {
      final totalMinutes = endTime.difference(startTime).inMinutes;
      final elapsedMinutes = now.difference(startTime).inMinutes;
      progress = elapsedMinutes / totalMinutes;
    }

    // Aulas antigas ficam ligeiramente apagadas
    final double cardOpacity = isPast ? 0.6 : 1.0;

    return Opacity(
      opacity: cardOpacity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        clipBehavior: Clip
            .antiAlias, // Necessário para a barra de progresso não vazar a borda arredondada
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isCurrent
              ? BorderSide(color: theme.colorScheme.primary, width: 2.0)
              : lesson.isExam
              ? BorderSide(color: theme.colorScheme.error, width: 1.5)
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
                  color: lesson.isExam ? theme.colorScheme.error : null,
                ),
              ),
              subtitle: Text(
                lesson.location,
                style: const TextStyle(fontSize: 13),
              ),
              trailing: lesson.isExam
                  ? Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
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
                    ],
                  ),
                ),
              ],
            ),
            // A barra de progresso no rodapé do card
            if (isCurrent || isPast)
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
