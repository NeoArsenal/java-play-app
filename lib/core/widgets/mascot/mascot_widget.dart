import 'package:flutter/widgets.dart';
import '../../services/feedback_settings.dart';
import 'custom_paint_mascot_renderer.dart';
import 'mascot_renderer.dart';
import 'mascot_state.dart';

/// Widget principal de la Mascota "Javi" (la taza de café de JavaPlay).
///
/// Expone el estado emocional [MascotState] y el tamaño [size].
/// Utiliza por defecto [CustomPaintMascotRenderer] pero admite cualquier
/// implementación de [MascotRenderer] para futura integración con Rive.
class MascotWidget extends StatelessWidget {
  final MascotState state;
  final double size;
  final MascotRenderer renderer;

  const MascotWidget({
    super.key,
    required this.state,
    this.size = 64.0,
    this.renderer = const CustomPaintMascotRenderer(),
  });

  String get _semanticsLabel {
    switch (state) {
      case MascotState.idle:
        return 'Javi la taza de café está descansando';
      case MascotState.thinking:
        return 'Javi la taza de café está pensando';
      case MascotState.happy:
        return 'Javi la taza de café está feliz';
      case MascotState.sad:
        return 'Javi la taza de café está triste';
      case MascotState.celebrate:
        return 'Javi la taza de café está celebrando';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduced = FeedbackSettings.isReducedMotion(context);

    return Semantics(
      label: _semanticsLabel,
      image: true,
      child: renderer.build(
        context: context,
        state: state,
        size: size,
        reducedMotion: reduced,
      ),
    );
  }
}
