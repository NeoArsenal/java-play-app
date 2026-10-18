import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'feedback_settings.dart';

class FeedbackService {
  static FeedbackService? _instance;
  static FeedbackService get instance => _instance ??= FeedbackService();

  static void setMockInstance(FeedbackService mock) {
    _instance = mock;
  }

  static void resetInstance() {
    _instance = null;
  }

  final AudioPlayer? _player;

  FeedbackService({AudioPlayer? player}) : _player = player;

  AudioPlayer get _audioPlayer => _player ?? AudioPlayer();

  Future<void> onCorrect() async {
    if (FeedbackSettings.isVibrationEnabled) {
      try {
        await HapticFeedback.lightImpact();
      } catch (_) {}
    }
    await _playSound('sounds/correct.mp3');
  }

  Future<void> onWrong() async {
    if (FeedbackSettings.isVibrationEnabled) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    await _playSound('sounds/wrong.mp3');
  }

  Future<void> onLessonComplete() async {
    if (FeedbackSettings.isVibrationEnabled) {
      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {}
    }
    await _playSound('sounds/complete.mp3');
  }

  Future<void> onBossHit() async {
    if (FeedbackSettings.isVibrationEnabled) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    await _playSound('sounds/hit.mp3');
  }

  Future<void> _playSound(String soundAsset) async {
    if (!FeedbackSettings.isSoundEnabled) return;
    try {
      final player = _audioPlayer;
      await player.stop();
      await player.play(AssetSource(soundAsset));
    } catch (_) {
      // Modo silencioso: no lanza excepciones si el archivo no existe o falla el decoder
    }
  }

  void dispose() {
    _player?.dispose();
  }
}
