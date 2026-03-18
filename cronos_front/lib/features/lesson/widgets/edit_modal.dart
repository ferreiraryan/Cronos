import 'package:cronos_front/app/repository/schedule_repository.dart';
import 'package:cronos_front/features/lesson/models/class_lesson.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class LessonEditModal extends StatefulWidget {
  final Lesson lesson;
  final DateTime dayDate;

  const LessonEditModal({
    super.key,
    required this.lesson,
    required this.dayDate,
  });

  static void show(BuildContext context, Lesson lesson, DateTime dayDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: LessonEditModal(lesson: lesson, dayDate: dayDate),
      ),
    );
  }

  @override
  State<LessonEditModal> createState() => _LessonEditModalState();
}

class _LessonEditModalState extends State<LessonEditModal> {
  late TextEditingController _topicCtrl;
  late TextEditingController _summaryCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _refsCtrl;
  late TextEditingController _cancelReasonCtrl;

  late bool _isExam;
  late bool _isCancelled;
  bool _applyLocationToAll = false;

  @override
  void initState() {
    super.initState();
    _topicCtrl = TextEditingController(text: widget.lesson.topic);
    _summaryCtrl = TextEditingController(text: widget.lesson.summary);
    _locationCtrl = TextEditingController(text: widget.lesson.location);
    _refsCtrl = TextEditingController(
      text: widget.lesson.references.join(', '),
    );
    _cancelReasonCtrl = TextEditingController(
      text: widget.lesson.metadata.cancelReason,
    );
    _isExam = widget.lesson.isExam;
    _isCancelled = widget.lesson.metadata.isCancelled;
  }

  @override
  void dispose() {
    _topicCtrl.dispose();
    _summaryCtrl.dispose();
    _locationCtrl.dispose();
    _refsCtrl.dispose();
    _cancelReasonCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final updatedMetadata = widget.lesson.metadata.copyWith(
      isCancelled: _isCancelled,
      cancelReason: _cancelReasonCtrl.text.trim().isEmpty
          ? null
          : _cancelReasonCtrl.text.trim(),
    );

    final updatedLesson = widget.lesson.copyWith(
      topic: _topicCtrl.text.trim().isEmpty ? null : _topicCtrl.text.trim(),
      summary: _summaryCtrl.text.trim().isEmpty
          ? null
          : _summaryCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      isExam: _isExam,
      references: _refsCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      metadata: updatedMetadata,
    );

    ScheduleRepository().updateLesson(
      dayDate: widget.dayDate,
      timeStart: widget.lesson.timeStart,
      updatedLesson: updatedLesson,
      applyLocationToAllFuture: _applyLocationToAll,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Editar: ${widget.lesson.subjectName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Toggle de Cancelamento
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Aula Cancelada?',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: _isCancelled,
              activeColor: Colors.redAccent,
              onChanged: (val) => setState(() => _isCancelled = val),
            ),

            if (_isCancelled) ...[
              TextField(
                controller: _cancelReasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Motivo do cancelamento (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _topicCtrl,
              decoration: const InputDecoration(
                labelText: 'Tópico da Aula',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _summaryCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Resumo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _refsCtrl,
              decoration: const InputDecoration(
                labelText: 'Referências (separadas por vírgula)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Local (Sala/Prédio)',
                border: OutlineInputBorder(),
              ),
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Aplicar este local para todas as aulas futuras desta matéria',
                style: TextStyle(fontSize: 13),
              ),
              value: _applyLocationToAll,
              onChanged: (val) =>
                  setState(() => _applyLocationToAll = val ?? false),
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'É uma Avaliação / Exame?',
                style: TextStyle(color: Colors.orangeAccent),
              ),
              value: _isExam,
              activeColor: Colors.orangeAccent,
              onChanged: (val) => setState(() => _isExam = val),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Salvar Alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
