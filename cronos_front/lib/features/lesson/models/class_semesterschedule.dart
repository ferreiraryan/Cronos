import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';

class SemesterSchedule {
  final String semester;
  final List<DaySchedule> schedule;

  SemesterSchedule({required this.semester, required this.schedule});

  factory SemesterSchedule.fromjson(Map<String, dynamic> json) {
    return SemesterSchedule(
      semester: json['semester'] ?? '',
      schedule: (json['schedule'] as List)
          .map((e) => DaySchedule.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'semester': semester,
    'schedule': schedule.map((e) => e.toJson()).toList(),
  };
}
