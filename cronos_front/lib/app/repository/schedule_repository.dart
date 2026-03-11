import 'dart:convert';
import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';
import 'package:cronos_front/features/lesson/models/class_semesterschedule.dart';
import 'package:flutter/services.dart';

// (Mantenha as suas classes Metadata, Lesson, DaySchedule, SemesterSchedule aqui)

class ScheduleRepository {
  SemesterSchedule? _cachedSchedule;

  /// Lê o JSON bruto (faz cache na memória para não reler o arquivo do disco atoa)
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
      throw Exception('Falha ao carregar o cronograma: $e');
    }
  }

  /// Retorna apenas os dias da semana atual (Segunda a Domingo)
  Future<List<Dayschedule>> getThisWeekSchedule() async {
    final fullSchedule = await loadFullSchedule();

    // Normaliza a data de hoje para 00:00:00 para evitar bugs de timezone/horas
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Matemática simples para achar a Segunda e o Domingo desta semana
    // No Dart, DateTime.monday = 1 e sunday = 7
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    // Filtra apenas as datas que estão dentro do range da semana
    return fullSchedule.schedule.where((day) {
      // Normaliza a data do model para garantir que estamos comparando maçãs com maçãs
      final targetDate = DateTime(day.date.year, day.date.month, day.date.day);

      return targetDate.isAfter(
            startOfWeek.subtract(const Duration(days: 1)),
          ) &&
          targetDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  /// Retorna apenas as aulas de Hoje
  Future<Dayschedule?> getTodaySchedule() async {
    final fullSchedule = await loadFullSchedule();
    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      // .first onde a string da data bate
      return fullSchedule.schedule.firstWhere(
        (day) => day.date.toIso8601String().startsWith(todayStr),
      );
    } catch (_) {
      return null; // Nenhuma aula hoje
    }
  }
}
