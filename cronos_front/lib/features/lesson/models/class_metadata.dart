class Metadata {
  final String customNotes;
  final double? grade;
  final int absenceCount;
  final bool isCancelled;
  final String? cancelReason;

  Metadata({
    this.customNotes = '',
    this.grade,
    this.absenceCount = 0,
    this.isCancelled = false,
    this.cancelReason,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    customNotes: json['custom_notes']?.toString() ?? '',
    grade: json['grade'] != null ? (json['grade'] as num).toDouble() : null,
    absenceCount: json['absence_count'] ?? 0,
    isCancelled: json['is_cancelled'] ?? false,
    cancelReason: json['cancel_reason']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'custom_notes': customNotes,
    if (grade != null) 'grade': grade,
    'absence_count': absenceCount,
    'is_cancelled': isCancelled,
    if (cancelReason != null) 'cancel_reason': cancelReason,
  };

  Metadata copyWith({
    String? customNotes,
    double? grade,
    int? absenceCount,
    bool? isCancelled,
    String? cancelReason,
  }) {
    return Metadata(
      customNotes: customNotes ?? this.customNotes,
      grade: grade ?? this.grade,
      absenceCount: absenceCount ?? this.absenceCount,
      isCancelled: isCancelled ?? this.isCancelled,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }
}
