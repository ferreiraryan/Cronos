import 'package:cronos_front/app/repository/schedule_repository.dart';
import 'package:cronos_front/app/repository/study_repository.dart';
import 'package:cronos_front/features/lesson/screens/study_hub_screen.dart';
import 'package:flutter/material.dart';
import 'timeline_screen.dart';
import 'calendar_screen.dart';

import 'package:file_picker/file_picker.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late Future<void> _initFuture;
  bool _needsSetup = false;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    // Roda os dois inits em paralelo. Schedule retorna um bool agora.
    final results = await Future.wait([
      ScheduleRepository().init(),
      StudyRepository().init(),
    ]);

    final hasSchedule = results[0] as bool;
    _needsSetup = !hasSchedule;
  }

  Future<void> _pickAndImportJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        await ScheduleRepository().importSchedule(result.files.single.path!);
        setState(() => _needsSetup = false); // JSON importado, destrava o app
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('JSON inválido ou corrompido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSetupScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.file_upload_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Nenhum cronograma',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Selecione o arquivo database.json gerado pelo extrator Python para montar sua grade do semestre.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _pickAndImportJson,
                icon: const Icon(Icons.folder_open),
                label: const Text('Selecionar database.json'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Erro: \n${snapshot.error}')),
          );
        }

        // Intercepta a UI se não houver JSON salvo
        if (_needsSetup) {
          return _buildSetupScreen();
        }

        // App carregado e com dados
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Agenda PUC',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: AnimatedBuilder(
            animation: Listenable.merge([
              ScheduleRepository(),
              StudyRepository(),
            ]),
            builder: (context, _) {
              final schedule = ScheduleRepository().getThisWeekSchedule();

              return IndexedStack(
                index: _currentIndex,
                children: [
                  TimelineScreen(schedule: schedule),
                  const CalendarScreen(),
                  const StudyHubScreen(),
                ],
              );
            },
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.timeline),
                label: 'Timeline',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month),
                label: 'Mensal',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_library),
                label: 'Hub',
              ),
            ],
          ),
        );
      },
    );
  }
}
