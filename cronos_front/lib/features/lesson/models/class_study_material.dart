class StudyMaterial {
  final String id;
  final String subjectName;
  final String title;
  final int totalPages;
  final int readPages;

  StudyMaterial({
    required this.id,
    required this.subjectName,
    required this.title,
    required this.totalPages,
    this.readPages = 0,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) => StudyMaterial(
    id: json['id']?.toString() ?? '',
    subjectName: json['subject_name']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    totalPages: json['total_pages'] ?? 1,
    readPages: json['read_pages'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject_name': subjectName,
    'title': title,
    'total_pages': totalPages,
    'read_pages': readPages,
  };

  double get progress =>
      totalPages > 0 ? (readPages / totalPages).clamp(0.0, 1.0) : 0.0;
}
