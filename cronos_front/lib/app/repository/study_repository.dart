import 'dart:io';
import 'dart:convert';

import 'package:cronos_front/features/lesson/models/class_study_block.dart';
import 'package:cronos_front/features/lesson/models/class_study_material.dart';
import 'package:cronos_front/features/lesson/models/class_study_plan.dart';
import 'package:cronos_front/features/lesson/models/class_study_task.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StudyRepository extends ChangeNotifier {
  static final StudyRepository _instance = StudyRepository._internal();
  factory StudyRepository() => _instance;
  StudyRepository._internal();

  StudyPlan? _plan;
  File? _localFile;

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _localFile = File('${directory.path}/study_plan.json');

    if (!await _localFile!.exists()) {
      final defaultPlan = StudyPlan();
      await _localFile!.writeAsString(json.encode(defaultPlan.toJson()));
    }

    final jsonString = await _localFile!.readAsString();
    _plan = StudyPlan.fromJson(json.decode(jsonString));
    notifyListeners();
  }

  StudyPlan get plan {
    if (_plan == null) throw Exception("StudyRepository não inicializado.");
    return _plan!;
  }

  Future<void> _save() async {
    if (_localFile != null && _plan != null) {
      await _localFile!.writeAsString(json.encode(_plan!.toJson()));
      notifyListeners();
    }
  }

  void addStudyBlock(StudyBlock block) {
    _plan!.routine.add(block);
    _save();
  }

  void removeStudyBlock(String id) {
    _plan!.routine.removeWhere((b) => b.id == id);
    _save();
  }

  void addOrUpdateMaterial(StudyMaterial material) {
    final index = _plan!.materials.indexWhere((m) => m.id == material.id);
    if (index >= 0) {
      _plan!.materials[index] = material;
    } else {
      _plan!.materials.add(material);
    }
    _save();
  }

  void removeMaterial(String id) {
    _plan!.materials.removeWhere((m) => m.id == id);
    _save();
  }

  void toggleTask(String id) {
    final index = _plan!.tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      _plan!.tasks[index] = _plan!.tasks[index].copyWith(
        isDone: !_plan!.tasks[index].isDone,
      );
      _save();
    }
  }

  void addTask(StudyTask task) {
    _plan!.tasks.add(task);
    _save();
  }

  void removeTask(String id) {
    _plan!.tasks.removeWhere((t) => t.id == id);
    _save();
  }

  // --- Helpers para a UI ---
  List<StudyBlock> getBlocksForDay(int dayOfWeek) {
    if (_plan == null) return [];
    return _plan!.routine.where((b) => b.dayOfWeek == dayOfWeek).toList()
      ..sort((a, b) => a.timeStart.compareTo(b.timeStart));
  }
}
