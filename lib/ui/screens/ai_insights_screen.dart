import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../analytics/ai_clustering_engine.dart';
import '../../providers/mood_provider.dart';
import '../components/common_widgets.dart';

class AIInsightsScreen extends StatelessWidget {
  const AIInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);
    final summary = AIClusteringEngine.analyze(provider.entries);
    final totalDays = provider.entries
        .map((e) => DateTime.fromMillisecondsSinceEpoch(e.timestamp).day)
        .toSet()
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text("Inteligencia de Patrones")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de Transparencia / Explicabilidad & Privacidad Local
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Privacidad total: El análisis de patrones se ejecuta 100% en tu dispositivo local sin enviar información a servidores externos.",
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Protocolo de Riesgo Ético
            if (summary.triggerRiskProtocol) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade700, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Aviso de Apoyo Emocional",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary.riskProtocolMessage ?? "",
                      style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Alerta de Anomalía
            if (summary.hasAnomaly) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade700),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        summary.anomalyMessage ?? "",
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            const SectionLabel("Tipología y Agrupamiento de Días (Clustering)"),
            // Manejo de Cold Start (3 días vs. 90)
            if (totalDays < 5)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.grey, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      "Estado Cold Start ($totalDays/5 días requeridos)",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Se requieren al menos 5 días de registro para poder agrupar tus patrones emocionales con validez estocástica.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: summary.clusters.map((c) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.label,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.description,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Muestra: ${c.dayCount} días",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Ánimo: ${c.avgMood.toStringAsFixed(1)}",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Energía: ${c.avgEnergy.toStringAsFixed(1)}",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          if (c.topActivities.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              "Actividades comunes: ${c.topActivities.join(', ')}",
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),
            const SectionLabel("Recomendaciones Personalizadas"),
            if (summary.recommendations.isEmpty)
              const Text(
                "Aún no hay suficientes hábitos correlacionados para estimar sugerencias personales con significancia estadística.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              )
            else
              Column(
                children: summary.recommendations.map((r) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.activity,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  r.suggestionText,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "Baseline Δ: +${r.expectedMoodGain.toStringAsFixed(2)} pts | ${r.confidenceInterval}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.deepPurple.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}