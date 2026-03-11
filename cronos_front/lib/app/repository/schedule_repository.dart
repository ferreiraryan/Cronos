import 'dart:convert';

import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';
import 'package:cronos_front/features/lesson/models/class_semesterschedule.dart';
import 'package:flutter/services.dart';

class ScheduleRepository {
  SemesterSchedule? _cachedSchedule;

  Future<SemesterSchedule> loadFullSchedule() async {
    if (_cachedSchedule != null) return _cachedSchedule!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/database.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      _cachedSchedule = SemesterSchedule.fromjson(jsonMap);
      return _cachedSchedule!;
    } catch (e) {
      throw Exception('Falha ao desserializar o JSON: $e');
    }
  }

  Future<List<DaySchedule>> getThisWeekSchedule() async {
    final fullSchedule = await loadFullSchedule();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return fullSchedule.schedule.where((day) {
      final targetDate = DateTime(day.date.year, day.date.month, day.date.day);

      return targetDate.isAfter(
            startOfWeek.subtract(const Duration(days: 1)),
          ) &&
          targetDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  Future<DaySchedule?> getTodaySchedule() async {
    final fullSchedule = await loadFullSchedule();
    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      return fullSchedule.schedule.firstWhere((day) {
        return day.date.toIso8601String().startsWith(todayStr);
      });
    } catch (_) {
      return null;
    }
  }
}
