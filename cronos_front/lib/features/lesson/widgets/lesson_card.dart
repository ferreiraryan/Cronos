import 'package:cronos_front/features/lesson/models/class_lesson.dart';
import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;

  const LessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: lesson.isExam
            ? BorderSide(color: theme.colorScheme.error, width: 1.5)
            : BorderSide.none,
      ),
      child: ExpansionTile(
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
        subtitle: Text(lesson.location, style: const TextStyle(fontSize: 13)),
        trailing: lesson.isExam
            ? Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error)
            : null,
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
                      padding: const EdgeInsets.only(left: 28.0, bottom: 4.0),
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
