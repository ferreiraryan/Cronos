class StudyTask {
  final String id;
  final String? subjectName;
  final String title;
  final bool isDone;
  final DateTime? date;
  final String? time;
  final bool isDaily;

  StudyTask({
    required this.id,
    this.subjectName,
    required this.title,
    this.isDone = false,
    this.date,
    this.time,
    this.isDaily = false,
  });

  factory StudyTask.fromJson(Map<String, dynamic> json) => StudyTask(
    id: json['id']?.toString() ?? '',
    subjectName: json['subject_name']?.toString(),
    title: json['title']?.toString() ?? '',
    isDone: json['is_done'] ?? false,
    date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
    time: json['time']?.toString(),
    isDaily: json['is_daily'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    if (subjectName != null) 'subject_name': subjectName,
    'title': title,
    'is_done': isDone,
    if (date != null) 'date': date!.toIso8601String(),
    if (time != null) 'time': time,
    'is_daily': isDaily,
  };

  StudyTask copyWith({bool? isDone}) {
    return StudyTask(
      id: id,
      subjectName: subjectName,
      title: title,
      date: date,
      time: time,
      isDaily: isDaily,
      isDone: isDone ?? this.isDone,
    );
  }
}
