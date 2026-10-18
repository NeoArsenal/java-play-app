import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/feedback_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _sound;
  late bool _vibration;
  late bool _reducedMotion;

  @override
  void initState() {
    super.initState();
    _sound = FeedbackSettings.isSoundEnabled;
    _vibration = FeedbackSettings.isVibrationEnabled;
    _reducedMotion = FeedbackSettings.isReducedMotion();
  }

  @override
  Widget build(BuildContext context) {
    final systemAnimationsDisabled = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final isReduced = FeedbackSettings.isReducedMotion(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Ajustes e Inmersión',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              'EXPERIENCIA SENSORIAL',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_rounded, color: AppColors.primaryGreen),
                  title: const Text(
                    'Efectos de sonido',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Sonidos al acertar, fallar y completar lecciones',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  value: _sound,
                  activeThumbColor: AppColors.primaryGreen,
                  onChanged: (val) {
                    setState(() => _sound = val);
                    FeedbackSettings.isSoundEnabled = val;
                  },
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration_rounded, color: AppColors.duolingoOrange),
                  title: const Text(
                    'Vibración háptica',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Vibración táctil al responder o derrotar jefes',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  value: _vibration,
                  activeThumbColor: AppColors.duolingoOrange,
                  onChanged: (val) {
                    setState(() => _vibration = val);
                    FeedbackSettings.isVibrationEnabled = val;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              'ACCESIBILIDAD Y RENDIMIENTO',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              secondary: const Icon(Icons.motion_photos_off_rounded, color: AppColors.duolingoBlue),
              title: const Text(
                'Animaciones reducidas',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                systemAnimationsDisabled
                    ? 'Activado por configuración del sistema'
                    : (isReduced
                        ? 'Activado manualmente (poses estáticas sin bucles)'
                        : 'Muestra animaciones dinámicas completas'),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              value: _reducedMotion,
              activeThumbColor: AppColors.duolingoBlue,
              onChanged: (val) {
                setState(() => _reducedMotion = val);
                FeedbackSettings.userReducedMotionOverride = val;
              },
            ),
          ),
        ],
      ),
    );
  }
}
