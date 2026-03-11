class StudyTask {
  final String id;
  final String subjectName;
  final String title;
  final bool isDone;

  StudyTask({
    required this.id,
    required this.subjectName,
    required this.title,
    this.isDone = false,
  });

  factory StudyTask.fromJson(Map<String, dynamic> json) => StudyTask(
    id: json['id']?.toString() ?? '',
    subjectName: json['subject_name']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    isDone: json['is_done'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject_name': subjectName,
    'title': title,
    'is_done': isDone,
  };
}
