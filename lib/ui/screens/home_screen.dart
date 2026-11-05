import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/mood_entry.dart';
import '../../models/mood_level.dart';
import '../../providers/mood_provider.dart';
import '../components/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  final void Function(MoodEntry?, [DateTime?]) onOpenEntry;

  const HomeScreen({super.key, required this.onOpenEntry});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);
    final entries = provider.entries;

    final Map<String, MoodEntry> byDate = {};
    for (var e in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(e.timestamp));
      if (!byDate.containsKey(dateKey)) {
        byDate[dateKey] = e;
      }
    }

    final selectedKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final todayEntry = byDate[selectedKey];
    final isTodaySelected = _isSameDay(_selectedDate, DateTime.now());

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderColor = isDark ? Colors.white24 : Colors.black12;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.userName.isEmpty ? "Fonn" : "Hola, ${provider.userName}",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        DateFormat('EEEE d "de" MMMM', 'es_MX').format(DateTime.now()),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: "Registrar hoy",
                    onPressed: () => widget.onOpenEntry(null, DateTime.now()),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const SectionLabel("Últimos días"),
              Row(
                children: List.generate(7, (index) {
                  final day = DateTime.now().subtract(Duration(days: 6 - index));
                  final key = DateFormat('yyyy-MM-dd').format(day);
                  final entry = byDate[key];
                  final isSelected = key == selectedKey;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDate = day),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : defaultBorderColor,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Text(DateFormat('E', 'es_MX').format(day).substring(0, 1).toUpperCase()),
                            const SizedBox(height: 6),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: entry != null
                                    ? moodFor(entry.mood).color
                                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(day.day.toString()),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              const Hairline(),
              const SectionLabel("Detalle"),
              Expanded(
                child: todayEntry == null
                    ? GestureDetector(
                        onTap: () => widget.onOpenEntry(null, _selectedDate),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: Border.all(color: defaultBorderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Sin registro", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                isTodaySelected
                                    ? "Toca para registrar cómo te sientes hoy"
                                    : "No hay registro almacenado para esta fecha pasadas",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => widget.onOpenEntry(todayEntry),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: defaultBorderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(moodFor(todayEntry.mood).emoji, style: const TextStyle(fontSize: 30)),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(moodFor(todayEntry.mood).label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text("Energía ${todayEntry.energy}/10", style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              if (todayEntry.note.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(todayEntry.note),
                              ]
                            ],
                          ),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}