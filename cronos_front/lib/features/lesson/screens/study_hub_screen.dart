import 'package:cronos_front/app/repository/schedule_repository.dart';
import 'package:cronos_front/app/repository/study_repository.dart';
import 'package:cronos_front/features/lesson/models/class_study_material.dart';
import 'package:cronos_front/features/lesson/models/class_study_task.dart';
import 'package:flutter/material.dart';

class StudyHubScreen extends StatefulWidget {
  const StudyHubScreen({super.key});

  @override
  State<StudyHubScreen> createState() => _StudyHubScreenState();
}

class _StudyHubScreenState extends State<StudyHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Extrai lista única de matérias da grade atual
  List<String> _getUniqueSubjects() {
    try {
      final schedule = ScheduleRepository().schedule;
      final subjects = schedule.schedule
          .expand((day) => day.lessons)
          .map((lesson) => lesson.subjectName)
          .toSet()
          .toList();
      subjects.sort();
      return subjects;
    } catch (_) {
      return [];
    }
  }

  void _showAddTaskDialog() {
    final titleCtrl = TextEditingController();
    final subjects = _getUniqueSubjects();

    String? selectedSubject;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    bool isDaily = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return AlertDialog(
            title: const Text('Novo Evento / Tarefa'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'O que fazer? (ex: Lista 3)',
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(
                      labelText: 'Matéria Contexto',
                    ),
                    value: selectedSubject,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Nenhuma (Geral)'),
                      ),
                      ...subjects.map(
                        (sub) => DropdownMenuItem(
                          value: sub,
                          child: Text(sub, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (val) =>
                        setStateModal(() => selectedSubject = val),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Repete todos os dias?'),
                    value: isDaily,
                    onChanged: (val) => setStateModal(() => isDaily = val),
                  ),

                  if (!isDaily)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        selectedDate == null
                            ? 'Selecionar Data'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today, size: 20),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null)
                          setStateModal(() => selectedDate = date);
                      },
                    ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      selectedTime == null
                          ? 'Selecionar Horário'
                          : selectedTime!.format(context),
                    ),
                    trailing: const Icon(Icons.access_time, size: 20),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null)
                        setStateModal(() => selectedTime = time);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    final formattedTime = selectedTime != null
                        ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                        : null;

                    StudyRepository().addTask(
                      StudyTask(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        subjectName: selectedSubject,
                        title: titleCtrl.text.trim(),
                        isDaily: isDaily,
                        date: isDaily ? null : selectedDate,
                        time: formattedTime,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddMaterialDialog() {
    final titleCtrl = TextEditingController();
    final pagesCtrl = TextEditingController();
    final subjects = _getUniqueSubjects();
    String? selectedSubject;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return AlertDialog(
            title: const Text('Novo Material'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String?>(
                  decoration: const InputDecoration(labelText: 'Matéria'),
                  value: selectedSubject,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Nenhuma')),
                    ...subjects.map(
                      (sub) => DropdownMenuItem(
                        value: sub,
                        child: Text(sub, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (val) =>
                      setStateModal(() => selectedSubject = val),
                  isExpanded: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título (ex: Haliday Vol 1)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pagesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total de Páginas',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final pages = int.tryParse(pagesCtrl.text) ?? 0;
                  if (titleCtrl.text.isNotEmpty && pages > 0) {
                    StudyRepository().addOrUpdateMaterial(
                      StudyMaterial(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        subjectName: selectedSubject ?? 'Geral',
                        title: titleCtrl.text.trim(),
                        totalPages: pages,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUpdateProgressDialog(StudyMaterial material) {
    final readCtrl = TextEditingController(text: material.readPages.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Progresso: ${material.title}'),
        content: TextField(
          controller: readCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Páginas lidas (Total: ${material.totalPages})',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final read = int.tryParse(readCtrl.text) ?? material.readPages;
              StudyRepository().addOrUpdateMaterial(
                StudyMaterial(
                  id: material.id,
                  subjectName: material.subjectName,
                  title: material.title,
                  totalPages: material.totalPages,
                  readPages: read.clamp(0, material.totalPages),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.event_note), text: 'Eventos/Tarefas'),
          Tab(icon: Icon(Icons.menu_book), text: 'Materiais'),
        ],
      ),
      body: AnimatedBuilder(
        animation: StudyRepository(),
        builder: (context, _) {
          final plan = StudyRepository().plan;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTasksTab(plan.tasks),
              _buildMaterialsTab(plan.materials),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tabController.index == 0
            ? _showAddTaskDialog
            : _showAddMaterialDialog,
        icon: Icon(
          _tabController.index == 0 ? Icons.add_task : Icons.library_add,
        ),
        label: Text(
          _tabController.index == 0 ? 'Nova Tarefa' : 'Novo Material',
        ),
      ),
    );
  }

  Widget _buildTasksTab(List<StudyTask> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma tarefa ou evento.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final sortedTasks = List<StudyTask>.from(tasks)
      ..sort((a, b) => a.isDone == b.isDone ? 0 : (a.isDone ? 1 : -1));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 16),
      itemCount: sortedTasks.length,
      itemBuilder: (context, index) {
        final task = sortedTasks[index];

        // Monta a string de metadados (Data/Hora)
        List<String> meta = [];
        if (task.isDaily) meta.add('Diário');
        if (task.date != null && !task.isDaily)
          meta.add('${task.date!.day}/${task.date!.month}');
        if (task.time != null) meta.add(task.time!);
        final metaString = meta.join(' • ');

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: CheckboxListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isDone ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.subjectName != null)
                  Text(
                    task.subjectName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                if (metaString.isNotEmpty)
                  Text(
                    metaString,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            value: task.isDone,
            onChanged: (_) => StudyRepository().toggleTask(task.id),
          ),
        );
      },
    );
  }

  Widget _buildMaterialsTab(List<StudyMaterial> materials) {
    if (materials.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum material rastreado.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 16),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final mat = materials[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showUpdateProgressDialog(mat),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mat.subjectName,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mat.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${mat.readPages} / ${mat.totalPages} pág.',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${(mat.progress * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: mat.progress),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
