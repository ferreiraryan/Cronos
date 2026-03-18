import 'package:cronos_front/features/lesson/models/class_metadata.dart';

class Lesson {
  final String timeStart;
  final String timeEnd;
  final String subjectId;
  final String subjectName;
  final String location;
  final String? topic;
  final String? summary;
  final List<String> references;
  final bool isExam;
  final Metadata metadata;

  Lesson({
    required this.timeStart,
    required this.timeEnd,
    required this.subjectId,
    required this.subjectName,
    required this.location,
    this.topic,
    this.summary,
    required this.references,
    this.isExam = false,
    required this.metadata,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      timeStart: json['time_start']?.toString() ?? '',
      timeEnd: json['time_end']?.toString() ?? '',
      subjectId: json['subject_id']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      topic: json['topic']?.toString(),
      summary: json['summary']?.toString(),
      references:
          (json['references'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isExam: json['is_exam'] ?? false,
      metadata: json['metadata'] != null
          ? Metadata.fromJson(json['metadata'])
          : Metadata(),
    );
  }

  Map<String, dynamic> toJson() => {
    'time_start': timeStart,
    'time_end': timeEnd,
    'subject_id': subjectId,
    'subject_name': subjectName,
    'location': location,
    if (topic != null) 'topic': topic,
    if (summary != null) 'summary': summary,
    'references': references,
    'is_exam': isExam,
    'metadata': metadata.toJson(),
  };

  Lesson copyWith({
    String? location,
    String? topic,
    String? summary,
    List<String>? references,
    bool? isExam,
    Metadata? metadata,
  }) {
    return Lesson(
      timeStart: timeStart,
      timeEnd: timeEnd,
      subjectId: subjectId,
      subjectName: subjectName,
      metadata: metadata ?? this.metadata,
      location: location ?? this.location,
      topic: topic ?? this.topic,
      summary: summary ?? this.summary,
      references: references ?? this.references,
      isExam: isExam ?? this.isExam,
    );
  }
}
