import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_provider.dart';
import '../components/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onChangePin;
  final VoidCallback onOpenCredits;
  final VoidCallback onOpenBackup;
  final VoidCallback onOpenReports;
  final VoidCallback onOpenReminders;

  const SettingsScreen({
    super.key,
    required this.onChangePin,
    required this.onOpenCredits,
    required this.onOpenBackup,
    required this.onOpenReports,
    required this.onOpenReminders,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MoodProvider>(context, listen: false);
    _controller = TextEditingController(text: provider.userName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Ajustes")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionLabel("Identidad"),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "¿Cómo te llamas?",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              provider.setUserName(_controller.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Nombre guardado")),
              );
            },
            child: const Text("GUARDAR NOMBRE"),
          ),
          const SectionLabel("Módulos de la Etapa 2"),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text("Reportes PDF"),
            onTap: widget.onOpenReports,
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Respaldo Cifrado"),
            onTap: widget.onOpenBackup,
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Recordatorios"),
            onTap: widget.onOpenReminders,
          ),
          const SectionLabel("Apariencia"),
          SwitchListTile(
            title: const Text("Tema oscuro"),
            value: provider.darkMode,
            onChanged: (val) => provider.setDarkMode(val),
          ),
          const SectionLabel("Seguridad"),
          ListTile(
            title: Text(provider.pin == null ? "Crear PIN" : "Cambiar PIN"),
            subtitle: Text(provider.pin == null ? "Sin PIN configurado" : "PIN activo"),
            trailing: const Icon(Icons.chevron_right),
            onTap: widget.onChangePin,
          ),
          SwitchListTile(
            title: const Text("Bloqueo automático"),
            subtitle: const Text("Requiere PIN al iniciar la aplicación"),
            value: provider.autoLock,
            onChanged: provider.pin == null ? null : (val) => provider.setAutoLock(val),
          ),
          const SectionLabel("Acerca de"),
          ListTile(
            title: const Text("Créditos"),
            trailing: const Icon(Icons.chevron_right),
            onTap: widget.onOpenCredits,
          ),
        ],
      ),
    );
  }
}