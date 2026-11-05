import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créditos")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text("Fonn / MoodWave", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text("Diario de emociones y hábitos"),
          SizedBox(height: 20),
          Text("Institución: Instituto Politécnico Nacional - UPIIT"),
          Text("Desarrollo: Cristian Leal Rivera"),
          Text("Tecnologías: Flutter (Dart) Multiplataforma"),
          SizedBox(height: 20),
          Text("© 2026 · Etapa 2"),
        ],
      ),
    );
  }
}