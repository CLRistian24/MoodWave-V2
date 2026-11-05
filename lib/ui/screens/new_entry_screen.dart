import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/mood_entry.dart';
import '../../models/mood_level.dart';
import '../../providers/mood_provider.dart';
import '../components/common_widgets.dart';

class NewEntryScreen extends StatefulWidget {
  final MoodEntry? initialEntry;
  final DateTime? initialDate;
  final bool isSyntheticTest;

  const NewEntryScreen({
    super.key,
    this.initialEntry,
    this.initialDate,
    this.isSyntheticTest = false,
  });

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  late int _mood;
  late int _energy;
  late TextEditingController _noteController;
  late Set<String> _selectedActivities;

  bool get _isEditable {
    if (widget.isSyntheticTest) return true;
    final targetDate = widget.initialEntry != null
        ? DateTime.fromMillisecondsSinceEpoch(widget.initialEntry!.timestamp)
        : (widget.initialDate ?? DateTime.now());
    final now = DateTime.now();
    return targetDate.year == now.year &&
        targetDate.month == now.month &&
        targetDate.day == now.day;
  }

  @override
  void initState() {
    super.initState();
    _mood = widget.initialEntry?.mood ?? 5;
    _energy = widget.initialEntry?.energy ?? 5;
    _noteController = TextEditingController(text: widget.initialEntry?.note ?? '');
    _selectedActivities = widget.initialEntry?.activityList.toSet() ?? {};
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderColor = isDark ? Colors.white24 : Colors.black12;

    final entryDate = widget.initialEntry != null
        ? DateTime.fromMillisecondsSinceEpoch(widget.initialEntry!.timestamp)
        : (widget.initialDate ?? DateTime.now());

    final canEdit = _isEditable;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialEntry == null ? "Nuevo registro" : "Detalle de registro",
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              DateFormat('d MMMM yyyy', 'es_MX').format(entryDate),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          if (widget.initialEntry?.id != null && canEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: "Eliminar registro",
              onPressed: () async {
                final provider = Provider.of<MoodProvider>(context, listen: false);
                final navigator = Navigator.of(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("¿Eliminar registro?"),
                    content: const Text("Esta acción no se puede deshacer."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("CANCELAR"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm != true || !mounted) return;
                await provider.deleteEntry(widget.initialEntry!.id!);
                navigator.pop();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!canEdit)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade700),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_clock, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Solo puedes crear o modificar registros pertenecientes al día de hoy. Las fechas pasadas o futuras se muestran en modo lectura.",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

            const SectionLabel("¿Cómo te sientes?"),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: moodLevels.map((m) {
                final isSelected = m.value == _mood;
                return GestureDetector(
                  onTap: canEdit ? () => setState(() => _mood = m.value) : null,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? m.color.withValues(alpha: 0.2) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? m.color : defaultBorderColor,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(m.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(m.label, style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const SectionLabel("Nivel de energía"),
            Row(
              children: List.generate(10, (i) {
                final val = i + 1;
                final isSelected = val == _energy;
                return Expanded(
                  child: GestureDetector(
                    onTap: canEdit ? () => setState(() => _energy = val) : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          val.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : (isDark ? Colors.white : Colors.black),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const SectionLabel("Actividades"),
            Wrap(
              spacing: 8,
              children: defaultActivities.map((act) {
                final isSelected = _selectedActivities.contains(act);
                return FilterChip(
                  label: Text(act),
                  selected: isSelected,
                  onSelected: canEdit
                      ? (sel) {
                          setState(() {
                            if (sel) {
                              _selectedActivities.add(act);
                            } else {
                              _selectedActivities.remove(act);
                            }
                          });
                        }
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const SectionLabel("Diario"),
            TextField(
              controller: _noteController,
              enabled: canEdit,
              maxLength: 280,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Escribe una pequeña reflexión...",
              ),
            ),
            const SizedBox(height: 24),
            if (canEdit)
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: () {
                  final timestamp = widget.initialEntry?.timestamp ??
                      (widget.initialDate?.millisecondsSinceEpoch ??
                          DateTime.now().millisecondsSinceEpoch);

                  final entry = MoodEntry(
                    id: widget.initialEntry?.id,
                    timestamp: timestamp,
                    mood: _mood,
                    energy: _energy,
                    note: _noteController.text.trim(),
                    activities: _selectedActivities.join('|'),
                  );
                  Provider.of<MoodProvider>(context, listen: false).saveEntry(entry);
                  Navigator.pop(context);
                },
                child: const Text("GUARDAR REGISTRO"),
              ),
          ],
        ),
      ),
    );
  }
}