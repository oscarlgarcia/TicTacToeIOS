import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_models.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  AudioPlayer? _backgroundMusicPlayer;
  AudioPlayer? _soundEffectsPlayer;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _volume = 0.5;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get volume => _volume;

  Future<void> init() async {
    _backgroundMusicPlayer = AudioPlayer();
    _soundEffectsPlayer = AudioPlayer();
    
    await _loadSettings();
    
    // Set volume for both players
    await _backgroundMusicPlayer?.setVolume(_volume * _musicEnabled ? 0.3 : 0.0);
    await _soundEffectsPlayer?.setVolume(_volume);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    _volume = prefs.getDouble('volume') ?? 0.5;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
    await prefs.setDouble('volume', _volume);
  }

  Future<void> playSound(SoundType type) async {
    if (!_soundEnabled) return;

    try {
      switch (type) {
        case SoundType.move:
          await _soundEffectsPlayer?.play(AssetSource('sounds/move.mp3'));
          break;
        case SoundType.win:
          await _soundEffectsPlayer?.play(AssetSource('sounds/win.mp3'));
          await Vibration.vibrate(pattern: [0, 200, 100, 200]);
          break;
        case SoundType.draw:
          await _soundEffectsPlayer?.play(AssetSource('sounds/draw.mp3'));
          await Vibration.vibrate(duration: 100);
          break;
        case SoundType.gameOver:
          await _soundEffectsPlayer?.play(AssetSource('sounds/game_over.mp3'));
          break;
        case SoundType.buttonClick:
          await _soundEffectsPlayer?.play(AssetSource('sounds/button_click.mp3'));
          await Vibration.vibrate(duration: 50);
          break;
        case SoundType.achievement:
          await _soundEffectsPlayer?.play(AssetSource('sounds/achievement.mp3'));
          await Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 200]);
          break;
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;

    try {
      await _backgroundMusicPlayer?.setReleaseMode(ReleaseMode.loop);
      await _backgroundMusicPlayer?.play(AssetSource('sounds/background_music.mp3'));
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer?.stop();
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer?.pause();
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_musicEnabled) return;

    try {
      await _backgroundMusicPlayer?.resume();
    } catch (e) {
      print('Error resuming background music: $e');
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    
    if (enabled) {
      await _backgroundMusicPlayer?.setVolume(_volume * 0.3);
      await playBackgroundMusic();
    } else {
      await _backgroundMusicPlayer?.setVolume(0.0);
    }
    
    await _saveSettings();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    
    await _soundEffectsPlayer?.setVolume(_volume);
    await _backgroundMusicPlayer?.setVolume(_volume * (_musicEnabled ? 0.3 : 0.0));
    
    await _saveSettings();
  }

  Future<void> fadeInBackgroundMusic({Duration duration = const Duration(seconds: 2)}) async {
    if (!_musicEnabled) return;

    final steps = 20;
    final stepDuration = duration.inMilliseconds ~/ steps;
    
    for (int i = 0; i <= steps; i++) {
      final currentVolume = (_volume * 0.3) * (i / steps);
      await _backgroundMusicPlayer?.setVolume(currentVolume);
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
  }

  Future<void> fadeOutBackgroundMusic({Duration duration = const Duration(seconds: 1)}) async {
    final steps = 20;
    final stepDuration = duration.inMilliseconds ~/ steps;
    final currentVolume = _volume * 0.3;
    
    for (int i = steps; i >= 0; i--) {
      final volume = currentVolume * (i / steps);
      await _backgroundMusicPlayer?.setVolume(volume);
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
    
    await stopBackgroundMusic();
  }

  void dispose() {
    _backgroundMusicPlayer?.dispose();
    _soundEffectsPlayer?.dispose();
  }
}