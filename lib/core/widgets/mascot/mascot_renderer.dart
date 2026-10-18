import 'package:flutter/widgets.dart';
import 'mascot_state.dart';

/// Interfaz abstracta para renderizar la mascota.
/// Permite intercambiar fácilmente la implementación de CustomPaint
/// por Rive o Lottie en el futuro sin modificar los widgets consumidores.
abstract class MascotRenderer {
  Widget build({
    required BuildContext context,
    required MascotState state,
    required double size,
    required bool reducedMotion,
  });
}
