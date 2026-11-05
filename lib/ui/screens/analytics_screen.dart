import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../analytics/analytics_engine.dart';
import '../../providers/mood_provider.dart';
import '../components/common_widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);
    final summary = AnalyticsEngine.process(provider.entries);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final recentEntries = provider.entries.take(30).toList().reversed.toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Descubre tus patrones", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.amber.shade900.withValues(alpha: 0.25) : Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade700),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Aviso: MoodWave no realiza diagnósticos médicos ni sustituye atención profesional.",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.amber.shade100 : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!summary.hasEnoughData)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(summary.statusMessage, textAlign: TextAlign.center),
                  ),
                )
              else ...[
                const SectionLabel("Estadísticas del Período"),
                const Text(
                  "• Promedio: Ánimo medio global (escala 1-8).\n"
                  "• Mediana: Valor central que divide tus registros.\n"
                  "• Desviación (σ): Variabilidad o dispersión de tus estados de ánimo.",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statCard("Promedio", summary.meanMood.toStringAsFixed(1), "de 8"),
                    _statCard("Mediana", summary.medianMood.toStringAsFixed(1), "de 8"),
                    _statCard("Desviación", summary.stdDevMood.toStringAsFixed(1), "σ"),
                    _statCard("Racha", "${summary.streakDays}", "días"),
                  ],
                ),
                const SizedBox(height: 20),
                const SectionLabel("Tendencia de Ánimo (Últimos días)"),
                const Text(
                  "Muestra la trayectoria continua de tu estado emocional a través del tiempo. Permite identificar picos y caídas continuas.",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: LineChart(
                        LineChartData(
                          minY: 1,
                          maxY: 8,
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 2,
                                getTitlesWidget: (val, meta) => Text(
                                  val.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 2,
                            getDrawingHorizontalLine: (val) => FlLine(
                              color: isDark ? Colors.white10 : Colors.black12,
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: recentEntries.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value.mood.toDouble());
                              }).toList(),
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SectionLabel("Asociación Actividad vs Ánimo"),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("¿Qué significan estos indicadores?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(height: 4),
                      Text("• n: Tamaño de muestra (cantidad de días que realizaste la actividad).", style: TextStyle(fontSize: 11)),
                      Text("• Cohen's d: Magnitud de efecto (>0.2 pequeño, >0.5 moderado, >0.8 alto).", style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                ...summary.activityImpacts.map((impact) {
                  final isPos = impact.diffFromMean >= 0;
                  return Card(
                    child: ListTile(
                      title: Text(impact.activity),
                      subtitle: Text("n = ${impact.sampleSize} | Cohen's d: ${impact.effectSize.toStringAsFixed(2)}"),
                      trailing: Text(
                        "${isPos ? '+' : ''}${impact.diffFromMean.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: isPos ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.dataset_outlined),
                  onPressed: () async {
                    await provider.seedSyntheticData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("90 días sintéticos cargados con éxito")),
                      );
                    }
                  },
                  label: const Text("Cargar 90 Días Sintéticos (Prueba Etapa 2)"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String val, String sub) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 10)),
              Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(sub, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}