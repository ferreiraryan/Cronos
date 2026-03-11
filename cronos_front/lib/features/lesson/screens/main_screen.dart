import 'package:cronos_front/app/repository/schedule_repository.dart';
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
  final ScheduleRepository _repository = ScheduleRepository();
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    // Inicializa a cópia do JSON para o storage local apenas uma vez
    _initFuture = _repository.init();
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
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro de I/O no JSON: \n${snapshot.error}'),
            );
          }

          // AnimatedBuilder faz a UI rebuildar automaticamente quando você salva uma edição no Modal
          return AnimatedBuilder(
            animation: _repository,
            builder: (context, _) {
              // Agora a chamada é síncrona, não precisa mais de await
              final schedule = _repository.getThisWeekSchedule();

              return IndexedStack(
                index: _currentIndex,
                children: [
                  TimelineScreen(schedule: schedule),
                  const CalendarScreen(),
                ],
              );
            },
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
