import 'dart:convert';
import 'dart:io';

import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';
import 'package:cronos_front/features/lesson/models/class_lesson.dart';
import 'package:cronos_front/features/lesson/models/class_semesterschedule.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

// ... [Mantenha os models idênticos (Metadata, Lesson, DaySchedule, SemesterSchedule)] ...

// ==========================================
// REPOSITORY
// ==========================================

class ScheduleRepository extends ChangeNotifier {
  static final ScheduleRepository _instance = ScheduleRepository._internal();
  factory ScheduleRepository() => _instance;
  ScheduleRepository._internal();

  SemesterSchedule? _cachedSchedule;
  File? _localFile;

  /// Retorna TRUE se o JSON já existe localmente, FALSE se for o primeiro acesso.
  Future<bool> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _localFile = File('${directory.path}/custom_schedule.json');

    if (!await _localFile!.exists()) {
      return false; // Precisa importar pelo File Picker
    }

    try {
      final jsonString = await _localFile!.readAsString();
      _cachedSchedule = SemesterSchedule.fromjson(json.decode(jsonString));
      notifyListeners();
      return true;
    } catch (e) {
      // Se o arquivo estiver corrompido, força a re-importação
      return false;
    }
  }

  /// Importa o JSON do File Picker, valida e salva no App
  Future<void> importSchedule(String filePath) async {
    final sourceFile = File(filePath);
    final jsonString = await sourceFile.readAsString();

    // Faz o parse para validar se é o JSON correto do extrator
    final parsedSchedule = SemesterSchedule.fromjson(json.decode(jsonString));

    if (_localFile == null) {
      final directory = await getApplicationDocumentsDirectory();
      _localFile = File('${directory.path}/custom_schedule.json');
    }

    await _localFile!.writeAsString(jsonString);
    _cachedSchedule = parsedSchedule;
    notifyListeners();
  }

  SemesterSchedule get schedule {
    if (_cachedSchedule == null)
      throw Exception("Repository não inicializado ou sem JSON.");
    return _cachedSchedule!;
  }

  // ... [Mantenha updateLesson e getThisWeekSchedule idênticos] ...
  Future<void> updateLesson({
    required DateTime dayDate,
    required String timeStart,
    required Lesson updatedLesson,
    required bool applyLocationToAllFuture,
  }) async {
    if (_cachedSchedule == null || _localFile == null) return;

    final dayIndex = _cachedSchedule!.schedule.indexWhere(
      (d) =>
          d.date.year == dayDate.year &&
          d.date.month == dayDate.month &&
          d.date.day == dayDate.day,
    );
    if (dayIndex == -1) return;

    final lessonIndex = _cachedSchedule!.schedule[dayIndex].lessons.indexWhere(
      (l) => l.timeStart == timeStart,
    );
    if (lessonIndex == -1) return;

    _cachedSchedule!.schedule[dayIndex].lessons[lessonIndex] = updatedLesson;

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

    await _localFile!.writeAsString(json.encode(_cachedSchedule!.toJson()));
    notifyListeners();
  }

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
