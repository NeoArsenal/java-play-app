import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona las preferencias de retroalimentación sensorial y accesibilidad:
/// - Sonido (efectos de audio)
/// - Vibración (retroalimentación háptica)
/// - Animaciones reducidas (accesibilidad motriz/visual)
class FeedbackSettings {
  static const String _keySound = 'pref_feedback_sound_enabled';
  static const String _keyVibration = 'pref_feedback_vibration_enabled';
  static const String _keyReducedMotion = 'pref_feedback_reduced_motion';

  static SharedPreferences? _prefs;

  static bool _soundEnabled = true;
  static bool _vibrationEnabled = true;
  static bool? _reducedMotionOverride;

  static final ValueNotifier<bool> soundNotifier = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> vibrationNotifier = ValueNotifier<bool>(true);
  static final ValueNotifier<bool?> reducedMotionNotifier = ValueNotifier<bool?>(null);

  /// Inicializa las preferencias leyendo valores persistidos en SharedPreferences
  static Future<void> initialize([SharedPreferences? injectedPrefs]) async {
    _prefs = injectedPrefs ?? await SharedPreferences.getInstance();
    _soundEnabled = _prefs?.getBool(_keySound) ?? true;
    _vibrationEnabled = _prefs?.getBool(_keyVibration) ?? true;
    _reducedMotionOverride = _prefs?.containsKey(_keyReducedMotion) == true
        ? _prefs?.getBool(_keyReducedMotion)
        : null;

    soundNotifier.value = _soundEnabled;
    vibrationNotifier.value = _vibrationEnabled;
    reducedMotionNotifier.value = _reducedMotionOverride;
  }

  /// Indica si el sonido está habilitado
  static bool get isSoundEnabled => _soundEnabled;

  static set isSoundEnabled(bool value) {
    _soundEnabled = value;
    soundNotifier.value = value;
    _prefs?.setBool(_keySound, value);
  }

  /// Indica si la vibración (háptica) está habilitada
  static bool get isVibrationEnabled => _vibrationEnabled;

  static set isVibrationEnabled(bool value) {
    _vibrationEnabled = value;
    vibrationNotifier.value = value;
    _prefs?.setBool(_keyVibration, value);
  }

  /// Override explícito del usuario para animaciones reducidas (null si sigue al sistema)
  static bool? get userReducedMotionOverride => _reducedMotionOverride;

  /// Retorna si las animaciones reducidas están activadas.
  /// Si el usuario configuró una preferencia explícita, se respeta esa preferencia.
  /// En caso contrario, consulta [MediaQuery.maybeDisableAnimationsOf(context)] o false.
  static bool isReducedMotion([BuildContext? context]) {
    if (_reducedMotionOverride != null) {
      return _reducedMotionOverride!;
    }
    if (context != null) {
      return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    }
    return false;
  }

  static set userReducedMotionOverride(bool? value) {
    _reducedMotionOverride = value;
    reducedMotionNotifier.value = value;
    if (value == null) {
      _prefs?.remove(_keyReducedMotion);
    } else {
      _prefs?.setBool(_keyReducedMotion, value);
    }
  }
}
