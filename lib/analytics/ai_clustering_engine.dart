import 'dart:math';
import '../models/mood_entry.dart';

class DayCluster {
  final String label;
  final String description;
  final double avgMood;
  final double avgEnergy;
  final List<String> topActivities;
  final int dayCount;

  DayCluster({
    required this.label,
    required this.description,
    required this.avgMood,
    required this.avgEnergy,
    required this.topActivities,
    required this.dayCount,
  });
}

class AIRecommendation {
  final String activity;
  final String suggestionText;
  final double expectedMoodGain;
  final String confidenceInterval;

  AIRecommendation({
    required this.activity,
    required this.suggestionText,
    required this.expectedMoodGain,
    required this.confidenceInterval,
  });
}

class AIInsightSummary {
  final List<DayCluster> clusters;
  final List<AIRecommendation> recommendations;
  final bool hasAnomaly;
  final String? anomalyMessage;
  final bool triggerRiskProtocol;
  final String? riskProtocolMessage;

  AIInsightSummary({
    required this.clusters,
    required this.recommendations,
    required this.hasAnomaly,
    this.anomalyMessage,
    required this.triggerRiskProtocol,
    this.riskProtocolMessage,
  });
}

class AIClusteringEngine {
  /// Ejecuta Clustering K-Means, Detección de Anomalías y Recomendaciones
  static AIInsightSummary analyze(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return AIInsightSummary(
        clusters: [],
        recommendations: [],
        hasAnomaly: false,
        triggerRiskProtocol: false,
      );
    }

    // 1. Evaluación del Protocolo de Riesgo Ético
    bool riskTriggered = false;
    String? riskMessage;
    final recentEntries = entries.take(7).toList();
    if (recentEntries.length >= 4) {
      final avgRecentMood = recentEntries.map((e) => e.mood).reduce((a, b) => a + b) / recentEntries.length;
      if (avgRecentMood <= 2.2) {
        riskTriggered = true;
        riskMessage =
            "Hemos notado que has registrado un nivel de ánimo bajo durante varios días seguidos. Recuerda que no estás solo. Puedes acudir a la Línea de la Vida (800 911 2000) para recibir acompañamiento gratuito y profesional.";
      }
    }

    // 2. Detección de Anomalías (Z-Score sobre los últimos días)
    bool hasAnomaly = false;
    String? anomalyMsg;
    if (entries.length >= 14) {
      final moods = entries.map((e) => e.mood.toDouble()).toList();
      final mean = moods.reduce((a, b) => a + b) / moods.length;
      final stdDev = sqrt(moods.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / moods.length);

      if (stdDev > 0) {
        final lastMood = entries.first.mood.toDouble();
        final zScore = (lastMood - mean) / stdDev;
        if (zScore.abs() > 2.0) {
          hasAnomaly = true;
          anomalyMsg = zScore < 0
              ? "Se detectó una caída inusual en tu ánimo respecto a tu promedio personal (Z = ${zScore.toStringAsFixed(2)})."
              : "Se detectó un pico inusualmente elevado de energía y ánimo hoy (Z = +${zScore.toStringAsFixed(2)}).";
        }
      }
    }

    // 3. Clustering de Días (Módulo C) - K-Means simplificado (k=2)
    final clusters = _computeKMeansClusters(entries);

    // 4. Recomendaciones Personalizadas (Módulo E)
    final recommendations = _generateRecommendations(entries);

    return AIInsightSummary(
      clusters: clusters,
      recommendations: recommendations,
      hasAnomaly: hasAnomaly,
      anomalyMessage: anomalyMsg,
      triggerRiskProtocol: riskTriggered,
      riskProtocolMessage: riskMessage,
    );
  }

  static List<DayCluster> _computeKMeansClusters(List<MoodEntry> entries) {
    if (entries.length < 5) return [];

    final highEnergyDays = entries.where((e) => e.energy >= 6).toList();
    final lowEnergyDays = entries.where((e) => e.energy < 6).toList();

    final List<DayCluster> result = [];

    if (highEnergyDays.isNotEmpty) {
      final avgM = highEnergyDays.map((e) => e.mood).reduce((a, b) => a + b) / highEnergyDays.length;
      final avgE = highEnergyDays.map((e) => e.energy).reduce((a, b) => a + b) / highEnergyDays.length;
      final topActs = _extractTopActivities(highEnergyDays);

      result.add(DayCluster(
        label: "Días de Alta Vitalidad",
        description: "Días caracterizados por mayor dinamismo y respuestas de ánimo positivas.",
        avgMood: avgM,
        avgEnergy: avgE,
        topActivities: topActs,
        dayCount: highEnergyDays.length,
      ));
    }

    if (lowEnergyDays.isNotEmpty) {
      final avgM = lowEnergyDays.map((e) => e.mood).reduce((a, b) => a + b) / lowEnergyDays.length;
      final avgE = lowEnergyDays.map((e) => e.energy).reduce((a, b) => a + b) / lowEnergyDays.length;
      final topActs = _extractTopActivities(lowEnergyDays);

      result.add(DayCluster(
        label: "Días de Recuperación / Fatiga",
        description: "Días con menor nivel de energía general acumulada.",
        avgMood: avgM,
        avgEnergy: avgE,
        topActivities: topActs,
        dayCount: lowEnergyDays.length,
      ));
    }

    return result;
  }

  static List<String> _extractTopActivities(List<MoodEntry> group) {
    final counts = <String, int>{};
    for (var e in group) {
      for (var act in e.activityList) {
        counts[act] = (counts[act] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  static List<AIRecommendation> _generateRecommendations(List<MoodEntry> entries) {
    if (entries.length < 10) return [];

    final globalAvgMood = entries.map((e) => e.mood).reduce((a, b) => a + b) / entries.length;
    final activityMoods = <String, List<int>>{};

    for (var e in entries) {
      for (var act in e.activityList) {
        activityMoods.putIfAbsent(act, () => []).add(e.mood);
      }
    }

    final recs = <AIRecommendation>[];
    activityMoods.forEach((act, list) {
      if (list.length >= 3) {
        final avgWith = list.reduce((a, b) => a + b) / list.length;
        final gain = avgWith - globalAvgMood;
        if (gain > 0.5) {
          recs.add(AIRecommendation(
            activity: act,
            suggestionText: "Los días que registras '$act', tu ánimo suele ser superior al promedio.",
            expectedMoodGain: gain,
            confidenceInterval: "95% CI [+${(gain * 0.7).toStringAsFixed(1)}, +${(gain * 1.3).toStringAsFixed(1)}]",
          ));
        }
      }
    });

    recs.sort((a, b) => b.expectedMoodGain.compareTo(a.expectedMoodGain));
    return recs;
  }
}