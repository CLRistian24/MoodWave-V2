import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_provider.dart';
import '../components/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenCredits;

  const ProfileScreen({super.key, required this.onOpenSettings, required this.onOpenCredits});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Perfil", style: Theme.of(context).textTheme.headlineMedium),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: "Ajustes",
                    onPressed: onOpenSettings,
                  ),
                ],
              ),
              if (provider.userName.isNotEmpty)
                Text(
                  provider.userName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              const SizedBox(height: 20),
              const SectionLabel("Métricas"),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text("Total de registros acumulados"),
                  trailing: Text(
                    "${provider.entries.length}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SectionLabel("Información"),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("Créditos"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onOpenCredits,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}