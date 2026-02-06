import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';

class SettingsController extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _volume = 0.5;
  bool _vibrationEnabled = true;
  bool _darkMode = false;
  String _language = 'es';
  bool _animationsEnabled = true;
  bool _hapticFeedbackEnabled = true;

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get volume => _volume;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get darkMode => _darkMode;
  String get language => _language;
  bool get animationsEnabled => _animationsEnabled;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;

  // Initialize settings
  Future<void> init() async {
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    _volume = prefs.getDouble('volume') ?? 0.5;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    _darkMode = prefs.getBool('darkMode') ?? false;
    _language = prefs.getString('language') ?? 'es';
    _animationsEnabled = prefs.getBool('animationsEnabled') ?? true;
    _hapticFeedbackEnabled = prefs.getBool('hapticFeedbackEnabled') ?? true;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
    await prefs.setDouble('volume', _volume);
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setString('language', _language);
    await prefs.setBool('animationsEnabled', _animationsEnabled);
    await prefs.setBool('hapticFeedbackEnabled', _hapticFeedbackEnabled);
  }

  // Sound settings
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _saveSettings();
  }

  // Vibration settings
  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    await _saveSettings();
  }

  // Theme settings
  Future<void> setDarkMode(bool enabled) async {
    _darkMode = enabled;
    await _saveSettings();
  }

  // Language settings
  Future<void> setLanguage(String language) async {
    _language = language;
    await _saveSettings();
  }

  // Animation settings
  Future<void> setAnimationsEnabled(bool enabled) async {
    _animationsEnabled = enabled;
    await _saveSettings();
  }

  // Haptic feedback settings
  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    _hapticFeedbackEnabled = enabled;
    await _saveSettings();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    _soundEnabled = true;
    _musicEnabled = true;
    _volume = 0.5;
    _vibrationEnabled = true;
    _darkMode = false;
    _language = 'es';
    _animationsEnabled = true;
    _hapticFeedbackEnabled = true;
    await _saveSettings();
    notifyListeners();
  }

  // Export settings
  Map<String, dynamic> exportSettings() {
    return {
      'soundEnabled': _soundEnabled,
      'musicEnabled': _musicEnabled,
      'volume': _volume,
      'vibrationEnabled': _vibrationEnabled,
      'darkMode': _darkMode,
      'language': _language,
      'animationsEnabled': _animationsEnabled,
      'hapticFeedbackEnabled': _hapticFeedbackEnabled,
    };
  }

  // Import settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    _soundEnabled = settings['soundEnabled'] ?? true;
    _musicEnabled = settings['musicEnabled'] ?? true;
    _volume = (settings['volume'] ?? 0.5).toDouble().clamp(0.0, 1.0);
    _vibrationEnabled = settings['vibrationEnabled'] ?? true;
    _darkMode = settings['darkMode'] ?? false;
    _language = settings['language'] ?? 'es';
    _animationsEnabled = settings['animationsEnabled'] ?? true;
    _hapticFeedbackEnabled = settings['hapticFeedbackEnabled'] ?? true;
    await _saveSettings();
    notifyListeners();
  }

  // Get theme mode
  ThemeMode get themeMode {
    switch (_language) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return _darkMode ? ThemeMode.dark : ThemeMode.light;
    }
  }

  // Get locale
  Locale get locale {
    final parts = _language.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(_language);
  }

  // Check if first launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('launched_before') ?? false);
  }

  // Mark as launched
  Future<void> markLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('launched_before', true);
  }

  // App version tracking
  Future<String> getLastAppVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_app_version') ?? '';
  }

  Future<void> setLastAppVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_app_version', version);
  }

  // Analytics consent
  Future<bool> getAnalyticsConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('analytics_consent') ?? false;
  }

  Future<void> setAnalyticsConsent(bool consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('analytics_consent', consent);
  }
}