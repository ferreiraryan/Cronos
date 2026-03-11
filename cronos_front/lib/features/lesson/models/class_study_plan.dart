import 'package:cronos_front/features/lesson/models/class_study_block.dart';
import 'package:cronos_front/features/lesson/models/class_study_material.dart';
import 'package:cronos_front/features/lesson/models/class_study_task.dart';

class StudyPlan {
  List<StudyBlock> routine;
  List<StudyMaterial> materials;
  List<StudyTask> tasks;

  StudyPlan({
    this.routine = const [],
    this.materials = const [],
    this.tasks = const [],
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) => StudyPlan(
    routine:
        (json['routine'] as List<dynamic>?)
            ?.map((e) => StudyBlock.fromJson(e))
            .toList() ??
        [],
    materials:
        (json['materials'] as List<dynamic>?)
            ?.map((e) => StudyMaterial.fromJson(e))
            .toList() ??
        [],
    tasks:
        (json['tasks'] as List<dynamic>?)
            ?.map((e) => StudyTask.fromJson(e))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'routine': routine.map((e) => e.toJson()).toList(),
    'materials': materials.map((e) => e.toJson()).toList(),
    'tasks': tasks.map((e) => e.toJson()).toList(),
  };
}
