import 'package:cronos_front/features/lesson/models/class_dayschedule.dart';
import 'package:cronos_front/main.dart' show DaySection;
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

  List<DaySchedule> _getFilteredSchedule() {
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
    }
    return widget.schedule;
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
