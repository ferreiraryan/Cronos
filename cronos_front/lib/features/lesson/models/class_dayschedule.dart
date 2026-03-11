import 'package:cronos_front/features/lesson/models/class_lesson.dart';

class Dayschedule {
  final DateTime date;
  final int dayOfWeek;
  final List<Lesson> lessons;

  Dayschedule({
    required this.date,
    required this.lessons,
    required this.dayOfWeek,
  });

  factory Dayschedule.fromJson(Map<String, dynamic> json) {
    return Dayschedule(
      date: DateTime.parse(json['date']),
      dayOfWeek: json['day_of_week'] ?? 0,
      lessons: (json['lessons'] as List)
          .map((e) => Lesson.fromJson(e))
          .toList(),
    );
  }
}
