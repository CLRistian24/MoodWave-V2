// lib/models/mood_entry.dart
class MoodEntry {
  final int? id;
  final int timestamp;
  final int mood;
  final int energy;
  final String note;
  final String activities;

  MoodEntry({
    this.id,
    required this.timestamp,
    required this.mood,
    required this.energy,
    required this.note,
    required this.activities,
  });

  List<String> get activityList =>
      activities.isEmpty ? [] : activities.split('|');

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'timestamp': timestamp,
      'mood': mood,
      'energy': energy,
      'note': note,
      'activities': activities,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as int?,
      timestamp: map['timestamp'] as int,
      mood: map['mood'] as int,
      energy: map['energy'] as int,
      note: map['note'] as String,
      activities: map['activities'] as String,
    );
  }
}