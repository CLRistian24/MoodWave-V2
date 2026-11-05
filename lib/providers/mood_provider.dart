import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/prefs_manager.dart';
import '../models/mood_entry.dart';

class MoodProvider extends ChangeNotifier {
  final PrefsManager _prefs = PrefsManager();
  
  List<MoodEntry> _entries = [];
  String? _pin;
  bool _autoLock = true;
  bool _darkMode = false;
  String _userName = '';
  bool _isUnlocked = false;

  List<MoodEntry> get entries => _entries;
  String? get pin => _pin;
  bool get autoLock => _autoLock;
  bool get darkMode => _darkMode;
  String get userName => _userName;
  bool get isUnlocked => _isUnlocked;

  Future<void> loadInitialData() async {
    _entries = await DatabaseHelper.instance.getAllEntries();
    _pin = await _prefs.getPin();
    _autoLock = await _prefs.getAutoLock();
    _darkMode = await _prefs.getDarkMode();
    _userName = await _prefs.getUserName();
    
    if (_pin == null || _pin!.isEmpty || !_autoLock) {
      _isUnlocked = true;
    }
    notifyListeners();
  }

  Future<void> saveEntry(MoodEntry entry) async {
    if (entry.id == null || entry.id == 0) {
      await DatabaseHelper.instance.insert(entry);
    } else {
      await DatabaseHelper.instance.update(entry);
    }
    _entries = await DatabaseHelper.instance.getAllEntries();
    notifyListeners();
  }

  Future<void> deleteEntry(int id) async {
    await DatabaseHelper.instance.delete(id);
    _entries = await DatabaseHelper.instance.getAllEntries();
    notifyListeners();
  }

  Future<void> seedSyntheticData() async {
    await DatabaseHelper.instance.seed90DaysSyntheticData();
    _entries = await DatabaseHelper.instance.getAllEntries();
    notifyListeners();
  }

  void setUnlocked(bool value) {
    _isUnlocked = value;
    notifyListeners();
  }

  Future<void> setPin(String newPin) async {
    await _prefs.setPin(newPin);
    _pin = newPin;
    notifyListeners();
  }

  Future<void> clearPin() async {
    await _prefs.clearPin();
    _pin = null;
    notifyListeners();
  }

  Future<void> setAutoLock(bool value) async {
    await _prefs.setAutoLock(value);
    _autoLock = value;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setDarkMode(value);
    _darkMode = value;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    await _prefs.setUserName(name);
    _userName = name;
    notifyListeners();
  }
}