import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../analytics/analytics_engine.dart';
import '../../analytics/ai_clustering_engine.dart';
import '../../providers/mood_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Future<Uint8List> _generatePdf(MoodProvider provider, AnalyticsSummary summary, AIInsightSummary aiSummary) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm', 'es_MX').format(now);
    final userName = provider.userName.isEmpty ? "Usuario" : provider.userName;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MoodWave / Fonn',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.deepPurple900,
                        ),
                      ),
                      pw.Text(
                        'Reporte Integrado de Analítica de Patrones e IA',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Usuario: $userName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('Generado: $formattedDate', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1.5, color: PdfColors.deepPurple200),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Instituto Politécnico Nacional - UPIIT | Procesamiento 100% Local', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  pw.Text('Página ${context.pageNumber} de ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // 1. Descargo Ético Obligatorio / Banner de Apoyo
            if (aiSummary.triggerRiskProtocol)
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red50,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.red400),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('AVISO DE APOYO EMOCIONAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.red900)),
                    pw.SizedBox(height: 4),
                    pw.Text(aiSummary.riskProtocolMessage ?? '', style: const pw.TextStyle(fontSize: 9, color: PdfColors.red900)),
                  ],
                ),
              )
            else
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 14),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber50,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.amber400),
                ),
                child: pw.Text(
                  'Aviso Ético: MoodWave no realiza diagnósticos médicos ni sustituye la atención profesional de salud mental.',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.brown900),
                ),
              ),

            // 2. Tarjetas de KPIs y Estadísticas del Período
            pw.Text('MÉTRICAS Y ESTADÍSTICAS DEL PERÍODO', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple900)),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _pdfStatCard('Ánimo Promedio', '${summary.meanMood.toStringAsFixed(1)} / 8', PdfColors.deepPurple50),
                _pdfStatCard('Energía Promedio', '${summary.meanEnergy.toStringAsFixed(1)} / 10', PdfColors.blue50),
                _pdfStatCard('Desviación (σ)', summary.stdDevMood.toStringAsFixed(2), PdfColors.teal50),
                _pdfStatCard('Racha Acumulada', '${summary.streakDays} días', PdfColors.orange50),
              ],
            ),
            pw.SizedBox(height: 16),

            // 3. Gráfica de Líneas / Histograma Visual del Ánimo
            pw.Text('TENDENCIA EMOCIONAL CONTINUA', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple900)),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
                color: PdfColors.grey50,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Evolución diaria del ánimo (Últimos 15 registros)', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: provider.entries.take(15).toList().reversed.map((e) {
                      final height = (e.mood / 8.0) * 45.0;
                      return pw.Column(
                        children: [
                          pw.Container(
                            width: 12,
                            height: height,
                            decoration: pw.BoxDecoration(
                              color: e.mood >= 6 ? PdfColors.green400 : (e.mood <= 3 ? PdfColors.red400 : PdfColors.amber400),
                              borderRadius: pw.BorderRadius.circular(2),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('${e.mood}', style: const pw.TextStyle(fontSize: 7)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // 4. Módulo de IA: Clustering y Tipología de Días
            pw.Text('INTEGRACIÓN DE IA: TIPOLOGÍA DE DÍAS (CLUSTERING)', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple900)),
            pw.SizedBox(height: 6),
            if (aiSummary.clusters.isEmpty)
              pw.Text('No hay datos suficientes para agrupar en tipologías (mínimo 5 días).', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600))
            else
              pw.Column(
                children: aiSummary.clusters.map((c) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 6),
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(4),
                      color: PdfColors.white,
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(c.label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                              pw.Text(c.description, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                              if (c.topActivities.isNotEmpty)
                                pw.Text('Hábitos: ${c.topActivities.join(', ')}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple700)),
                            ],
                          ),
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('${c.dayCount} días', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                            pw.Text('Ánimo: ${c.avgMood.toStringAsFixed(1)} | Energ: ${c.avgEnergy.toStringAsFixed(1)}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            pw.SizedBox(height: 16),

            // 5. Módulo de IA: Recomendaciones Personalizadas
            pw.Text('INTEGRACIÓN DE IA: RECOMENDACIONES PERSONALIZADAS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple900)),
            pw.SizedBox(height: 6),
            if (aiSummary.recommendations.isEmpty)
              pw.Text('Aún no hay hábitos suficientes registrados para proyectar recomendaciones con intervalo de confianza.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600))
            else
              pw.Column(
                children: aiSummary.recommendations.map((r) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 6),
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.purple50,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: PdfColors.purple200),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('★', style: pw.TextStyle(color: PdfColors.amber800, fontSize: 12)),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(r.activity, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                              pw.Text(r.suggestionText, style: const pw.TextStyle(fontSize: 8.5)),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                "Baseline Δ: +${r.expectedMoodGain.toStringAsFixed(2)} pts | ${r.confidenceInterval}",
                                style: pw.TextStyle(fontSize: 7.5, color: PdfColors.deepPurple900, fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            pw.SizedBox(height: 16),

            // 6. Tabla de Impacto Actividad vs Ánimo (Estadística de Núcleo)
            pw.Text('ASOCIACIÓN ESTADÍSTICA (ACTIVIDAD VS. ÁNIMO)', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple900)),
            pw.SizedBox(height: 6),
            if (summary.activityImpacts.isEmpty)
              pw.Text('No hay suficientes datos acumulados para calcular correlaciones (mínimo n=5 por actividad).', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600))
            else
              pw.Table.fromTextArray(
                headers: ['Actividad', 'Muestra (n)', 'Cohen\'s d', 'Diferencia vs Media'],
                data: summary.activityImpacts.map((impact) {
                  final sign = impact.diffFromMean >= 0 ? '+' : '';
                  return [
                    impact.activity,
                    '${impact.sampleSize} registros',
                    impact.effectSize.toStringAsFixed(2),
                    '$sign${impact.diffFromMean.toStringAsFixed(2)} pts',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple700),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 8),
              ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pdfStatCard(String title, String value, PdfColor bgColor) {
    return pw.Container(
      width: 110,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title.toUpperCase(), style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700)),
          pw.SizedBox(height: 3),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);
    final summary = AnalyticsEngine.process(provider.entries);
    final aiSummary = AIClusteringEngine.analyze(provider.entries);

    return Scaffold(
      appBar: AppBar(title: const Text("Reportes y Exportación")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Informe Ejecutivo Integrado", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              "Genera un documento PDF que consolida tus métricas de tendencia, tablas de asociación y descubrimientos del módulo de Inteligencia Artificial.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.deepPurple, size: 36),
                title: const Text("Estado actual del informe"),
                subtitle: Text(
                  "Registros: ${summary.totalEntries} | Días: ${summary.totalDays} | Clusters IA: ${aiSummary.clusters.length} | Recs IA: ${aiSummary.recommendations.length}",
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.print),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async =>
                        await _generatePdf(provider, summary, aiSummary),
                    name: 'Reporte_Ejecutivo_MoodWave.pdf',
                  );
                },
                label: const Text("IMPRIMIR / GUARDAR REPORTE PDF COMPLETO"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}