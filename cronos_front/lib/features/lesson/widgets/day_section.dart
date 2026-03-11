import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';
import 'package:flutter/material.dart';
import 'lesson_card.dart';

class DaySection extends StatelessWidget {
  final DaySchedule dayData;

  const DaySection({super.key, required this.dayData});

  @override
  Widget build(BuildContext context) {
    final dataFormatada =
        "${dayData.date.day.toString().padLeft(2, '0')}/${dayData.date.month.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              dataFormatada,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...dayData.lessons.map((lesson) => LessonCard(lesson: lesson)),
        ],
      ),
    );
  }
}
