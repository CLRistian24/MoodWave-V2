import 'dart:math';
import '../models/mood_entry.dart';

class ActivityImpact {
  final String activity;
  final int sampleSize;
  final double avgMoodWith;
  final double diffFromMean;
  final double effectSize;

  ActivityImpact({
    required this.activity,
    required this.sampleSize,
    required this.avgMoodWith,
    required this.diffFromMean,
    required this.effectSize,
  });
}

class AnalyticsSummary {
  final int totalEntries;
  final int totalDays;
  final int streakDays;
  final double meanMood;
  final double medianMood;
  final int modeMood;
  final double stdDevMood;
  final double meanEnergy;
  final List<ActivityImpact> activityImpacts;
  final bool hasEnoughData;
  final String statusMessage;

  AnalyticsSummary({
    required this.totalEntries,
    required this.totalDays,
    required this.streakDays,
    required this.meanMood,
    required this.medianMood,
    required this.modeMood,
    required this.stdDevMood,
    required this.meanEnergy,
    required this.activityImpacts,
    required this.hasEnoughData,
    required this.statusMessage,
  });
}

class AnalyticsEngine {
  static const int minDays = 14;
  static const int minNPerActivity = 5;

  static AnalyticsSummary process(List<MoodEntry> entries) {
    final count = entries.length;
    final uniqueDays = entries
        .map((e) {
          final dt = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
          return DateTime(dt.year, dt.month, dt.day);
        })
        .toSet()
        .length;

    if (count == 0 || uniqueDays < minDays) {
      return AnalyticsSummary(
        totalEntries: count,
        totalDays: uniqueDays,
        streakDays: _calculateStreak(entries),
        meanMood: 0.0,
        medianMood: 0.0,
        modeMood: 0,
        stdDevMood: 0.0,
        meanEnergy: 0.0,
        activityImpacts: [],
        hasEnoughData: false,
        statusMessage: "Aún no hay datos suficientes. Se requieren al menos 14 días totales para mostrar patrones.",
      );
    }

    final moods = entries.map((e) => e.mood).toList();
    final energies = entries.map((e) => e.energy).toList();

    final meanMood = moods.reduce((a, b) => a + b) / moods.length;
    final medianMood = _calculateMedian(moods);
    final modeMood = _calculateMode(moods);
    final stdDevMood = _calculateStdDev(moods, meanMood);
    final meanEnergy = energies.reduce((a, b) => a + b) / energies.length;

    final Map<String, List<MoodEntry>> activityMap = {};
    for (var entry in entries) {
      for (var act in entry.activityList) {
        activityMap.putIfAbsent(act, () => []).add(entry);
      }
    }

    final impacts = <ActivityImpact>[];
    activityMap.forEach((act, withList) {
      if (withList.length >= minNPerActivity) {
        final withoutList = entries.where((e) => !e.activityList.contains(act)).toList();
        final avgWith = withList.map((e) => e.mood).reduce((a, b) => a + b) / withList.length;
        final diff = avgWith - meanMood;
        final cohenD = _calculateCohenD(withList.map((e) => e.mood).toList(), withoutList.map((e) => e.mood).toList());

        impacts.add(ActivityImpact(
          activity: act,
          sampleSize: withList.length,
          avgMoodWith: avgWith,
          diffFromMean: diff,
          effectSize: cohenD,
        ));
      }
    });

    impacts.sort((a, b) => b.diffFromMean.abs().compareTo(a.diffFromMean.abs()));

    return AnalyticsSummary(
      totalEntries: count,
      totalDays: uniqueDays,
      streakDays: _calculateStreak(entries),
      meanMood: meanMood,
      medianMood: medianMood,
      modeMood: modeMood,
      stdDevMood: stdDevMood,
      meanEnergy: meanEnergy,
      activityImpacts: impacts,
      hasEnoughData: true,
      statusMessage: "Se observa una relación estadísticamente relevante en tus registros acumulados.",
    );
  }

  static double _calculateMedian(List<int> list) {
    final sorted = List<int>.from(list)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length % 2 == 0) {
      return (sorted[mid - 1] + sorted[mid]) / 2.0;
    }
    return sorted[mid].toDouble();
  }

  static int _calculateMode(List<int> list) {
    final map = <int, int>{};
    for (var val in list) {
      map[val] = (map[val] ?? 0) + 1;
    }
    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static double _calculateStdDev(List<int> list, double mean) {
    if (list.length <= 1) return 0.0;
    final variance = list.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / (list.length - 1);
    return sqrt(variance);
  }

  static double _calculateCohenD(List<int> group1, List<int> group2) {
    if (group1.isEmpty || group2.isEmpty) return 0.0;
    final m1 = group1.reduce((a, b) => a + b) / group1.length;
    final m2 = group2.reduce((a, b) => a + b) / group2.length;
    final s1 = _calculateStdDev(group1, m1);
    final s2 = _calculateStdDev(group2, m2);
    final pooled = sqrt((pow(s1, 2) + pow(s2, 2)) / 2.0);
    return pooled == 0 ? 0.0 : (m1 - m2) / pooled;
  }

  static int _calculateStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;
    final days = entries
        .map((e) {
          final dt = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
          return DateTime(dt.year, dt.month, dt.day);
        })
        .toSet();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime checkDate = today;

    // Si hoy no se ha registrado, verifica si ayer se registró para continuar la racha
    if (!days.contains(checkDate)) {
      checkDate = today.subtract(const Duration(days: 1));
      if (!days.contains(checkDate)) {
        return 0;
      }
    }

    int streak = 0;
    while (days.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }
}