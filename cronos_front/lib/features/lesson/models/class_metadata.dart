class Metadata {
  final String customNotes;
  final double? grade;
  final int absenceCount;

  Metadata({this.customNotes = '', this.grade, this.absenceCount = 0});

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      customNotes: json['custom_notes']?.toString() ?? '',
      grade: json['grade'] != null ? (json['grade'] as num).toDouble() : null,
      absenceCount: json['absence_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'custom_notes': customNotes,
    if (grade != null) 'grade': grade,
    'absence_count': absenceCount,
  };
}
