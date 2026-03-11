import 'package:cronos_front/app/repository/schedule_repository.dart';
import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';
import 'package:cronos_front/features/lesson/models/class_lesson.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const PUCApp());
}

class PUCApp extends StatelessWidget {
  const PUCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cronograma PUC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late Future<List<Dayschedule>> _scheduleFuture;
  final ScheduleRepository _repository = ScheduleRepository();

  @override
  void initState() {
    super.initState();
    // Chama direto a função que já filtra a semana atual no repositório
    _scheduleFuture = _repository.getThisWeekSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agenda PUC',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Dayschedule>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar o JSON: \n${snapshot.error}'),
            );
          }

          final schedule = snapshot.data ?? [];

          return IndexedStack(
            index: _currentIndex,
            children: [
              TimelineView(schedule: schedule),
              const CalendarGridView(),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timeline), label: 'Timeline'),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Mensal',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// VIEWS
// ==========================================

class TimelineView extends StatefulWidget {
  final List<Dayschedule> schedule;

  const TimelineView({super.key, required this.schedule});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  String _filter = 'Hoje';

  List<Dayschedule> _getFilteredSchedule() {
    if (_filter == 'Hoje') {
      final now = DateTime.now();
      return widget.schedule
          .where(
            (day) =>
                day.date.year == now.year &&
                day.date.month == now.month &&
                day.date.day == now.day,
          )
          .toList();
    } else {
      // Retorna a semana toda (os dados já vieram filtrados do Repository)
      return widget.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDays = _getFilteredSchedule();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Hoje', label: Text('Hoje')),
              ButtonSegment(value: 'Semana', label: Text('Semana')),
            ],
            selected: {_filter},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() => _filter = newSelection.first);
            },
          ),
        ),
        Expanded(
          child: filteredDays.isEmpty
              ? const Center(child: Text('Nenhuma aula programada.'))
              : ListView.builder(
                  itemCount: filteredDays.length,
                  itemBuilder: (context, index) {
                    return DaySection(dayData: filteredDays[index]);
                  },
                ),
        ),
      ],
    );
  }
}

// ==========================================
// COMPONENTES
// ==========================================

class DaySection extends StatelessWidget {
  final Dayschedule dayData;

  const DaySection({super.key, required this.dayData});

  @override
  Widget build(BuildContext context) {
    // Formatação simples de data manual.
    // Para algo mais robusto ("24 de Fev"), adicione o package 'intl'
    final dataFormatada =
        "${dayData.date.day.toString().padLeft(2, '0')}/${dayData.date.month.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              dataFormatada,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...dayData.lessons
              .map((lesson) => LessonCard(lesson: lesson))
              .toList(),
        ],
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final Lesson lesson;

  const LessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: lesson.isExam
            ? BorderSide(color: theme.colorScheme.error, width: 1.5)
            : BorderSide.none,
      ),
      child: ExpansionTile(
        shape: const Border(),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lesson.timeStart,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              lesson.timeEnd,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        title: Text(
          lesson.subjectName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: lesson.isExam ? theme.colorScheme.error : null,
          ),
        ),
        subtitle: Text(lesson.location, style: const TextStyle(fontSize: 13)),
        trailing: lesson.isExam
            ? Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error)
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.subject,
                  'Tópico',
                  lesson.topic ?? 'Aula normal (Sem tópico especificado)',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.short_text,
                  'Resumo',
                  lesson.summary ?? 'Sem resumo detalhado',
                ),

                if (lesson.references.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.menu_book, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Referências:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...lesson.references.map(
                    (ref) => Padding(
                      padding: const EdgeInsets.only(left: 28.0, bottom: 4.0),
                      child: Text(
                        '• $ref',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(content, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

class CalendarGridView extends StatelessWidget {
  const CalendarGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Grid Mensal\n(Implementar package table_calendar aqui)',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
