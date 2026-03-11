import 'dart:convert';
import 'dart:io';

import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';
import 'package:cronos_front/features/lesson/models/class_lesson.dart';
import 'package:cronos_front/features/lesson/models/class_semesterschedule.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ScheduleRepository extends ChangeNotifier {
  static final ScheduleRepository _instance = ScheduleRepository._internal();
  factory ScheduleRepository() => _instance;
  ScheduleRepository._internal();

  SemesterSchedule? _cachedSchedule;
  File? _localFile;

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _localFile = File('${directory.path}/custom_schedule.json');

    if (!await _localFile!.exists()) {
      final String jsonString = await rootBundle.loadString(
        'assets/database.json',
      );
      await _localFile!.writeAsString(jsonString);
    }

    final jsonString = await _localFile!.readAsString();
    _cachedSchedule = SemesterSchedule.fromjson(json.decode(jsonString));
    notifyListeners();
  }

  SemesterSchedule get schedule {
    if (_cachedSchedule == null)
      throw Exception("Repository não inicializado.");
    return _cachedSchedule!;
  }

  /// Lógica Core: Atualiza uma aula específica e opcionalmente propaga o local
  Future<void> updateLesson({
    required DateTime dayDate,
    required String timeStart,
    required Lesson updatedLesson,
    required bool applyLocationToAllFuture,
  }) async {
    if (_cachedSchedule == null || _localFile == null) return;

    // 1. Encontra o dia exato
    final dayIndex = _cachedSchedule!.schedule.indexWhere(
      (d) =>
          d.date.year == dayDate.year &&
          d.date.month == dayDate.month &&
          d.date.day == dayDate.day,
    );
    if (dayIndex == -1) return;

    // 2. Encontra a aula exata naquele dia
    final lessonIndex = _cachedSchedule!.schedule[dayIndex].lessons.indexWhere(
      (l) => l.timeStart == timeStart,
    );
    if (lessonIndex == -1) return;

    // 3. Atualiza a aula específica
    _cachedSchedule!.schedule[dayIndex].lessons[lessonIndex] = updatedLesson;

    // 4. Propagação de Local (Apenas para aulas da mesma matéria, a partir daquela data)
    if (applyLocationToAllFuture) {
      for (int i = dayIndex; i < _cachedSchedule!.schedule.length; i++) {
        var futureDay = _cachedSchedule!.schedule[i];
        for (int j = 0; j < futureDay.lessons.length; j++) {
          var futureLesson = futureDay.lessons[j];
          if (futureLesson.subjectName == updatedLesson.subjectName) {
            futureDay.lessons[j] = futureLesson.copyWith(
              location: updatedLesson.location,
            );
          }
        }
      }
    }

    // 5. Persiste no disco e avisa a UI
    await _localFile!.writeAsString(json.encode(_cachedSchedule!.toJson()));
    notifyListeners();
  }

  // Helpers de filtro mantidos para a UI
  List<DaySchedule> getThisWeekSchedule() {
    if (_cachedSchedule == null) return [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _cachedSchedule!.schedule.where((day) {
      final target = DateTime(day.date.year, day.date.month, day.date.day);
      return target.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          target.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }
}
