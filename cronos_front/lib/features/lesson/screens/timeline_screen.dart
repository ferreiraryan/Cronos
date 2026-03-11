import 'dart:async';
import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';
import 'package:flutter/material.dart';
import '../widgets/day_section.dart';

class TimelineScreen extends StatefulWidget {
  final List<DaySchedule> schedule;

  const TimelineScreen({super.key, required this.schedule});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  String _filter = 'Hoje';
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Atualiza o estado da tela a cada 1 minuto para animar a barra de progresso
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime _parseLessonTime(DateTime dayDate, String time) {
    final parts = time.split(':');
    return DateTime(
      dayDate.year,
      dayDate.month,
      dayDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  List<DaySchedule> _getFilteredSchedule() {
    if (_filter == 'Hoje') {
      // 1. Busca se tem aula hoje
      var todaySchedule = widget.schedule
          .where(
            (day) =>
                day.date.year == _now.year &&
                day.date.month == _now.month &&
                day.date.day == _now.day,
          )
          .toList();

      if (todaySchedule.isNotEmpty) {
        // 2. Verifica se todas as aulas de hoje já terminarend
        final lastLesson = todaySchedule.first.lessons.last;
        final endTime = _parseLessonTime(
          todaySchedule.first.date,
          lastLesson.timeEnd,
        );

        if (_now.isAfter(endTime)) {
          // Hoje já acabou. Puxa o próximo dia letivo disponível no array.
          return widget.schedule
              .where((day) => day.date.isAfter(_now))
              .take(1)
              .toList();
        }
        return todaySchedule;
      } else {
        // Se hoje for feriado ou fds, já mostra direto o próximo dia com aulas
        return widget.schedule
            .where((day) => day.date.isAfter(_now))
            .take(1)
            .toList();
      }
    }
    return widget.schedule;
  }

  String _getBotaoDiaLabel(List<DaySchedule> filteredDays) {
    if (_filter != 'Hoje' || filteredDays.isEmpty) return 'Hoje';

    final firstDay = filteredDays.first.date;

    if (firstDay.year == _now.year &&
        firstDay.month == _now.month &&
        firstDay.day == _now.day) {
      return 'Hoje';
    }

    final tomorrow = _now.add(const Duration(days: 1));
    if (firstDay.year == tomorrow.year &&
        firstDay.month == tomorrow.month &&
        firstDay.day == tomorrow.day) {
      return 'Amanhã';
    }

    return 'Próximas';
  }

  @override
  Widget build(BuildContext context) {
    final filteredDays = _getFilteredSchedule();

    final labelDia = _getBotaoDiaLabel(filteredDays);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'Hoje', label: Text(labelDia)),
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
              ? const Center(child: Text('Nenhuma aula futura programada.'))
              : ListView.builder(
                  itemCount: filteredDays.length,
                  itemBuilder: (context, index) {
                    // Passamos o _now para a seção para sincronizar o progresso
                    return DaySection(dayData: filteredDays[index], now: _now);
                  },
                ),
        ),
      ],
    );
  }
}
