// lib/models/mood_level.dart
import 'package:flutter/material.dart';

class MoodLevel {
  final int value;
  final String label;
  final String emoji;
  final Color color;

  const MoodLevel({
    required this.value,
    required this.label,
    required this.emoji,
    required this.color,
  });
}

const List<MoodLevel> moodLevels = [
  MoodLevel(value: 1, label: "Radiactivo", emoji: "💥", color: Color(0xFFE53935)),
  MoodLevel(value: 2, label: "Enojado", emoji: "😡", color: Color(0xFFF4511E)),
  MoodLevel(value: 3, label: "Triste", emoji: "😢", color: Color(0xFF1E88E5)),
  MoodLevel(value: 4, label: "Ansioso", emoji: "😰", color: Color(0xFFFB8C00)),
  MoodLevel(value: 5, label: "Neutral", emoji: "😐", color: Color(0xFF757575)),
  MoodLevel(value: 6, label: "Tranquilo", emoji: "😌", color: Color(0xFF43A047)),
  MoodLevel(value: 7, label: "Feliz", emoji: "😊", color: Color(0xFFFDD835)),
  MoodLevel(value: 8, label: "Eufórico", emoji: "🤩", color: Color(0xFF8E24AA)),
];

MoodLevel moodFor(int value) {
  return moodLevels.firstWhere(
    (m) => m.value == value,
    orElse: () => moodLevels[4],
  );
}

const List<String> defaultActivities = [
  'Trabajo', 'Ejercicio', 'Lectura', 'Familia', 'Meditación', 'Fiesta', 'Descanso'
];