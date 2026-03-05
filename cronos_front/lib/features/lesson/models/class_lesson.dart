import 'package:flutter/material.dart';

class Lesson {
  final String id;
  final String name;
  final String location;
  final String topic;
  final String summary;
  final TimeOfDay timeStart;
  final TimeOfDay timeEnd;
  final List<String>? references;

  final bool isExam;

  Lesson({
    required this.id,
    required this.name,
    required this.location,
    required this.topic,
    required this.summary,
    required this.timeStart,
    required this.timeEnd,
    required this.references,
    required this.isExam,
  });

  Map<String, dynamic> toMap() {
    return {};
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['subject_id'] ?? "",
      name: json['subject_name'] ?? 'Nome não encontrado',
      location: json['location'] ?? '',
      topic: json['topic'] ?? '',
      summary: json['summary'] ?? '',
      timeStart: json['time_start'] ?? '',
      timeEnd: json['time_end'] ?? '',
      references: json['references'] ?? '',
      isExam: json['is_exam'] ?? '',
    );
  }
}
