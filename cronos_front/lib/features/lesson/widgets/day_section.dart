import 'package:cronos_front/app/repository/study_repository.dart';
import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';
import 'package:cronos_front/features/lesson/models/class_lesson.dart';
import 'package:cronos_front/features/lesson/models/class_study_block.dart';
import 'package:cronos_front/features/lesson/widgets/study_card.dart';
import 'package:flutter/material.dart';
import 'lesson_card.dart';

class DaySection extends StatelessWidget {
  final DaySchedule dayData;
  final DateTime now;

  const DaySection({super.key, required this.dayData, required this.now});

  @override
  Widget build(BuildContext context) {
    final dataFormatada =
        "${dayData.date.day.toString().padLeft(2, '0')}/${dayData.date.month.toString().padLeft(2, '0')}";

    // 1. Pega os blocos de estudo para o dia da semana atual
    final studyBlocks = StudyRepository().getBlocksForDay(dayData.date.weekday);

    // 2. Faz o merge das aulas com os blocos de estudo
    List<dynamic> combinedSchedule = [...dayData.lessons, ...studyBlocks];

    // 3. Ordena tudo cronologicamente
    combinedSchedule.sort(
      (a, b) => (a.timeStart as String).compareTo(b.timeStart as String),
    );

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
          // 4. Renderiza o card correspondente ao tipo de objeto
          ...combinedSchedule.map((item) {
            if (item is Lesson) {
              return LessonCard(lesson: item, dayDate: dayData.date, now: now);
            } else if (item is StudyBlock) {
              return StudyBlockCard(
                block: item,
                dayDate: dayData.date,
                now: now,
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }
}
