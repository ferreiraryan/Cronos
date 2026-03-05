import 'package:cronos_front/features/lesson/models/class_lesson.dart';

class Semester {
  final String date;
  final List<Lesson> lessons;

  Semester(this.lessons, {required this.date});
}
