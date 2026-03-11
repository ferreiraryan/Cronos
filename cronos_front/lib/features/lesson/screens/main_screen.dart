import 'package:cronos_front/app/repository/schedule_repository.dart';
import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';
import 'package:flutter/material.dart';
import 'timeline_screen.dart';
import 'calendar_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late Future<List<DaySchedule>> _scheduleFuture;
  final ScheduleRepository _repository = ScheduleRepository();

  @override
  void initState() {
    super.initState();
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
      body: FutureBuilder<List<DaySchedule>>(
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
              TimelineScreen(schedule: schedule),
              const CalendarScreen(),
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
