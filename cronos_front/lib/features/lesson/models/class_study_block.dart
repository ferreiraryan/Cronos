class StudyBlock {
  final String id;
  final String subjectName;
  final int
  dayOfWeek; // 1 = Segunda, 7 = Domingo (Padrão ISO 8601 / DateTime do Dart)
  final String timeStart;
  final String timeEnd;

  StudyBlock({
    required this.id,
    required this.subjectName,
    required this.dayOfWeek,
    required this.timeStart,
    required this.timeEnd,
  });

  factory StudyBlock.fromJson(Map<String, dynamic> json) => StudyBlock(
    id: json['id']?.toString() ?? '',
    subjectName: json['subject_name']?.toString() ?? '',
    dayOfWeek: json['day_of_week'] ?? 1,
    timeStart: json['time_start']?.toString() ?? '00:00',
    timeEnd: json['time_end']?.toString() ?? '00:00',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject_name': subjectName,
    'day_of_week': dayOfWeek,
    'time_start': timeStart,
    'time_end': timeEnd,
  };
}
