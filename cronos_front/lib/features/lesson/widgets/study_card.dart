import 'package:cronos_front/features/lesson/models/class_study_block.dart';
import 'package:flutter/material.dart';

class StudyBlockCard extends StatelessWidget {
  final StudyBlock block;
  final DateTime dayDate;
  final DateTime now;

  const StudyBlockCard({
    super.key,
    required this.block,
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

    final startTime = _parseTime(block.timeStart);
    final endTime = _parseTime(block.timeEnd);

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

    final double cardOpacity = isPast ? 0.6 : 1.0;
    final Color studyColor =
        Colors.tealAccent.shade400; // Destaque visual para estudo

    return Opacity(
      opacity: cardOpacity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isCurrent
              ? BorderSide(color: studyColor, width: 2.0)
              : const BorderSide(
                  color: Colors.white12,
                  width: 1.0,
                ), // Borda sutil para diferenciar de aulas
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    block.timeStart,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    block.timeEnd,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              title: Text(
                'Estudo: ${block.subjectName}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: studyColor,
                ),
              ),
              trailing: isCurrent
                  ? Icon(Icons.menu_book, color: studyColor)
                  : const Icon(Icons.menu_book, color: Colors.grey),
            ),
            if (isCurrent || isPast)
              LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.transparent,
                color: isPast ? Colors.grey.withOpacity(0.5) : studyColor,
              ),
          ],
        ),
      ),
    );
  }
}
