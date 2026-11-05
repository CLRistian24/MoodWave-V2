import 'package:flutter/material.dart';
import '../../data/prefs_manager.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final PrefsManager _prefs = PrefsManager();
  bool _enabled = true;
  TimeOfDay _time = const TimeOfDay(hour: 21, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedTime();
  }

  Future<void> _loadSavedTime() async {
    final h = await _prefs.getReminderHour();
    final m = await _prefs.getReminderMinute();
    setState(() {
      _time = TimeOfDay(hour: h, minute: m);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Recordatorios")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text("Notificación diaria"),
            subtitle: const Text("Recibe un aviso para registrar tu día"),
            value: _enabled,
            onChanged: (val) => setState(() => _enabled = val),
          ),
          ListTile(
            title: const Text("Hora del recordatorio"),
            subtitle: const Text("Toca para modificar la hora guardada"),
            trailing: Text(
              _time.format(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _time);
              if (picked != null) {
                setState(() => _time = picked);
                await _prefs.setReminderTime(picked.hour, picked.minute);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Hora de recordatorio guardada")),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}