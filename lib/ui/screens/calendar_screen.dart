import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/mood_entry.dart';
import '../../models/mood_level.dart';
import '../../providers/mood_provider.dart';

class CalendarScreen extends StatefulWidget {
  final void Function(MoodEntry?, [DateTime?]) onOpenEntry;

  const CalendarScreen({super.key, required this.onOpenEntry});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);
    final entries = provider.entries;

    final Map<String, MoodEntry> byDate = {};
    for (var e in entries) {
      final key = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(e.timestamp));
      byDate[key] = e;
    }

    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOffset = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday - 1;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderColor = isDark ? Colors.white24 : Colors.black12;
    final now = DateTime.now();

    const weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Calendario", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'es_MX').format(_currentMonth),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1)),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: weekdays.map((w) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        w,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 6),
              // Envolver el GridView dentro de Expanded para evitar overflows
              Expanded(
                child: SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: daysInMonth + firstDayOffset,
                    itemBuilder: (context, index) {
                      if (index < firstDayOffset) return const SizedBox();
                      final dayNum = index - firstDayOffset + 1;
                      final date = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                      final key = DateFormat('yyyy-MM-dd').format(date);
                      final entry = byDate[key];
                      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

                      return GestureDetector(
                        onTap: () => widget.onOpenEntry(entry, date),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : defaultBorderColor,
                              width: isToday ? 1.5 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayNum.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: entry != null
                                      ? moodFor(entry.mood).color
                                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}