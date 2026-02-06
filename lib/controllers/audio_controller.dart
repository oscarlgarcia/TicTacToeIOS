import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sound_service.dart';
import '../controllers/settings_controller.dart';

class AudioController extends ChangeNotifier {
  final SoundService _soundService = SoundService();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    await _soundService.init();
    _isInitialized = true;
    notifyListeners();
  }

  // Sound controls
  Future<void> playSound(SoundType type) async {
    await _soundService.playSound(type);
  }

  Future<void> playBackgroundMusic() async {
    await _soundService.playBackgroundMusic();
  }

  Future<void> stopBackgroundMusic() async {
    await _soundService.stopBackgroundMusic();
  }

  Future<void> pauseBackgroundMusic() async {
    await _soundService.pauseBackgroundMusic();
  }

  Future<void> resumeBackgroundMusic() async {
    await _soundService.resumeBackgroundMusic();
  }

  Future<void> fadeInBackgroundMusic({Duration duration = const Duration(seconds: 2)}) async {
    await _soundService.fadeInBackgroundMusic(duration: duration);
  }

  Future<void> fadeOutBackgroundMusic({Duration duration = const Duration(seconds: 1)}) async {
    await _soundService.fadeOutBackgroundMusic(duration: duration);
  }

  // Settings
  bool get soundEnabled => _soundService.soundEnabled;
  bool get musicEnabled => _soundService.musicEnabled;
  double get volume => _soundService.volume;

  Future<void> setSoundEnabled(bool enabled) async {
    await _soundService.setSoundEnabled(enabled);
    notifyListeners();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await _soundService.setMusicEnabled(enabled);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _soundService.setVolume(volume);
    notifyListeners();
  }

  // Convenience methods
  Future<void> playMoveSound() async {
    await playSound(SoundType.move);
  }

  Future<void> playWinSound() async {
    await playSound(SoundType.win);
  }

  Future<void> playDrawSound() async {
    await playSound(SoundType.draw);
  }

  Future<void> playButtonClickSound() async {
    await playSound(SoundType.buttonClick);
  }

  Future<void> playAchievementSound() async {
    await playSound(SoundType.achievement);
  }

  // Lifecycle management
  Future<void> onAppPaused() async {
    await pauseBackgroundMusic();
  }

  Future<void> onAppResumed() async {
    await resumeBackgroundMusic();
  }

  Future<void> onAppDetached() async {
    _soundService.dispose();
  }

  @override
  void dispose() {
    super.dispose();
  }
}