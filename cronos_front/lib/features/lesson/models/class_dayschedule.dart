import 'package:cronos_front/features/lesson/models/class_lesson.dart';

class DaySchedule {
  final DateTime date;
  final int dayOfWeek;
  List<Lesson> lessons;

  DaySchedule({
    required this.date,
    required this.dayOfWeek,
    required this.lessons,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    if (json['date'] != null) {
      try {
        parsedDate = DateTime.parse(json['date'].toString());
      } catch (_) {}
    }

    return DaySchedule(
      date: parsedDate,
      dayOfWeek: json['day_of_week'] ?? 0,
      lessons:
          (json['lessons'] as List<dynamic>?)
              ?.map((e) => Lesson.fromJson(e))
              .toList() ??
          [],
    );
  }
  Map<String, dynamic> toJson() => {
    'date':
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    'day_of_week': dayOfWeek,
    'lessons': lessons.map((e) => e.toJson()).toList(),
  };
}
