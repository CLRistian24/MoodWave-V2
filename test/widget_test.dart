import 'package:flutter_test/flutter_test.dart';
import 'package:moodwave/analytics/analytics_engine.dart';
import 'package:moodwave/models/mood_entry.dart';
import 'package:moodwave/models/mood_level.dart';

void main() {
  group('MoodEntry Tests', () {
    test('toMap and fromMap should preserve properties', () {
      final entry = MoodEntry(
        id: 1,
        timestamp: 1700000000000,
        mood: 7,
        energy: 8,
        note: 'Día productivo',
        activities: 'Trabajo|Ejercicio',
      );

      final map = entry.toMap();
      final fromMap = MoodEntry.fromMap(map);

      expect(fromMap.id, equals(1));
      expect(fromMap.timestamp, equals(1700000000000));
      expect(fromMap.mood, equals(7));
      expect(fromMap.energy, equals(8));
      expect(fromMap.note, equals('Día productivo'));
      expect(fromMap.activities, equals('Trabajo|Ejercicio'));
      expect(fromMap.activityList, equals(['Trabajo', 'Ejercicio']));
    });

    test('empty activities should return empty list', () {
      final entry = MoodEntry(
        timestamp: 1700000000000,
        mood: 5,
        energy: 5,
        note: '',
        activities: '',
      );

      expect(entry.activityList, isEmpty);
    });
  });

  group('MoodLevel Tests', () {
    test('moodFor should return exact MoodLevel when found', () {
      final mood1 = moodFor(1);
      expect(mood1.label, equals('Radiactivo'));
      expect(mood1.emoji, equals('💥'));

      final mood7 = moodFor(7);
      expect(mood7.label, equals('Feliz'));
      expect(mood7.emoji, equals('😊'));
    });

    test('moodFor should return default neutral when invalid value', () {
      final invalid = moodFor(99);
      expect(invalid.value, equals(5));
      expect(invalid.label, equals('Neutral'));
    });
  });

  group('AnalyticsEngine Tests', () {
    test('returns not enough data when entries are below 14 unique days', () {
      final now = DateTime.now();
      final entries = List.generate(5, (i) {
        return MoodEntry(
          timestamp: now.subtract(Duration(days: i)).millisecondsSinceEpoch,
          mood: 6,
          energy: 6,
          note: '',
          activities: 'Ejercicio',
        );
      });

      final summary = AnalyticsEngine.process(entries);
      expect(summary.hasEnoughData, isFalse);
      expect(summary.totalEntries, equals(5));
      expect(summary.totalDays, equals(5));
    });

    test('calculates accurate statistics and streak with 15 days of data', () {
      final now = DateTime.now();
      final entries = <MoodEntry>[];

      for (int i = 0; i < 15; i++) {
        entries.add(MoodEntry(
          timestamp: now.subtract(Duration(days: i)).millisecondsSinceEpoch,
          mood: (i % 2 == 0) ? 7 : 5,
          energy: 6,
          note: 'Nota $i',
          activities: (i % 2 == 0) ? 'Ejercicio' : 'Trabajo',
        ));
      }

      final summary = AnalyticsEngine.process(entries);
      expect(summary.hasEnoughData, isTrue);
      expect(summary.totalDays, equals(15));
      expect(summary.streakDays, equals(15));
      expect(summary.meanMood, closeTo(6.06, 0.1));
      expect(summary.medianMood, isIn([6.0, 7.0]));
      expect(summary.activityImpacts, isNotEmpty);
    });
  });
}
