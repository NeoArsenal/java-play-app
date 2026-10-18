import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'mascot_renderer.dart';
import 'mascot_state.dart';

/// Implementación de [MascotRenderer] que dibuja a la mascota "Javi"
/// (una taza de café interactiva con vapor y expresiones) usando CustomPaint.
class CustomPaintMascotRenderer implements MascotRenderer {
  const CustomPaintMascotRenderer();

  @override
  Widget build({
    required BuildContext context,
    required MascotState state,
    required double size,
    required bool reducedMotion,
  }) {
    return _AnimatedMascotView(
      state: state,
      size: size,
      reducedMotion: reducedMotion,
    );
  }
}

class _AnimatedMascotView extends StatefulWidget {
  final MascotState state;
  final double size;
  final bool reducedMotion;

  const _AnimatedMascotView({
    required this.state,
    required this.size,
    required this.reducedMotion,
  });

  @override
  State<_AnimatedMascotView> createState() => _AnimatedMascotViewState();
}

class _AnimatedMascotViewState extends State<_AnimatedMascotView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (!widget.reducedMotion) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedMascotView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion != oldWidget.reducedMotion) {
      if (widget.reducedMotion) {
        _controller.stop();
        _controller.value = 0.0;
      } else {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reducedMotion) {
      return RepaintBoundary(
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _MascotPainter(
            state: widget.state,
            animationProgress: 0.0,
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _MascotPainter(
              state: widget.state,
              animationProgress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final MascotState state;
  final double animationProgress; // 0.0 a 1.0

  static const Color cupColor = Color(0xFF8B5A2B); // Taza #8B5A2B
  static const Color creamColor = Color(0xFFF5E6CC); // Crema #F5E6CC
  static const Color accentColor = Color(0xFF58CC02); // Acentos #58CC02
  static const Color darkEspresso = Color(0xFF231205); // Expresión
  static const Color dropColor = Color(0xFF38BDF8); // Gota pensando

  _MascotPainter({
    required this.state,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Normalizar a lienzo virtual de 100x100
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Rebote o inclinación según el estado
    double translateY = 0.0;
    double rotation = 0.0;

    if (state == MascotState.happy) {
      translateY = -math.sin(animationProgress * math.pi * 2) * 4.0;
    } else if (state == MascotState.celebrate) {
      translateY = -(math.sin(animationProgress * math.pi * 4).abs()) * 6.0;
    } else if (state == MascotState.thinking) {
      rotation = -0.06;
    }

    canvas.translate(50, 50);
    if (rotation != 0) canvas.rotate(rotation);
    canvas.translate(-50, -50 + translateY);

    _drawSteam(canvas);
    _drawHandle(canvas);
    _drawCupBody(canvas);
    _drawCream(canvas);
    _drawFace(canvas);
    _drawStateAccessories(canvas);

    canvas.restore();
  }

  void _drawSteam(Canvas canvas) {
    final steamPaint = Paint()
      ..color = creamColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final phase = animationProgress * 2 * math.pi;

    // Tres estelas de vapor curvado ascendente
    final steamOffsets = [36.0, 48.0, 60.0];
    for (int i = 0; i < steamOffsets.length; i++) {
      final x = steamOffsets[i];
      final wave = math.sin(phase + (i * 1.5)) * 2.5;

      final path = Path();
      path.moveTo(x, 38);
      path.cubicTo(
        x + wave, 30,
        x - wave, 22,
        x + (wave * 0.5), 14,
      );
      canvas.drawPath(path, steamPaint);
    }
  }

  void _drawHandle(Canvas canvas) {
    final handlePaint = Paint()
      ..color = cupColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(70, 48);
    path.cubicTo(88, 48, 88, 72, 68, 72);
    canvas.drawPath(path, handlePaint);
  }

  void _drawCupBody(Canvas canvas) {
    final bodyPaint = Paint()
      ..color = cupColor
      ..style = PaintingStyle.fill;

    // Cuerpo de la taza trapezoidal redondeado
    final path = Path();
    path.moveTo(26, 42);
    path.lineTo(74, 42);
    path.lineTo(68, 78);
    path.cubicTo(66, 85, 34, 85, 32, 78);
    path.close();
    canvas.drawPath(path, bodyPaint);

    // Base inferior
    final basePaint = Paint()
      ..color = const Color(0xFF6E431E)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(36, 83, 28, 4),
        const Radius.circular(2),
      ),
      basePaint,
    );
  }

  void _drawCream(Canvas canvas) {
    final creamPaint = Paint()
      ..color = creamColor
      ..style = PaintingStyle.fill;

    // Espuma cremosa en el borde de la taza
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(24, 38, 52, 9),
        const Radius.circular(4.5),
      ),
      creamPaint,
    );

    // Ondulación de la crema
    final ripplePaint = Paint()
      ..color = const Color(0xFFE8D4B4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(34, 42), const Offset(66, 42), ripplePaint);
  }

  void _drawFace(Canvas canvas) {
    final eyePaint = Paint()
      ..color = darkEspresso
      ..style = PaintingStyle.fill;

    final mouthPaint = Paint()
      ..color = darkEspresso
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final blushPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    // Mejillas sonrosadas verdes de acento
    canvas.drawCircle(const Offset(34, 63), 3.0, blushPaint);
    canvas.drawCircle(const Offset(66, 63), 3.0, blushPaint);

    switch (state) {
      case MascotState.idle:
        // Parpadeo suave cada ciclo (último 12% del tiempo)
        final isBlinking = animationProgress > 0.88;
        if (isBlinking) {
          canvas.drawLine(const Offset(38, 56), const Offset(44, 56), mouthPaint);
          canvas.drawLine(const Offset(56, 56), const Offset(62, 56), mouthPaint);
        } else {
          canvas.drawCircle(const Offset(41, 56), 2.5, eyePaint);
          canvas.drawCircle(const Offset(59, 56), 2.5, eyePaint);
        }
        // Sonrisa leve
        final smile = Path()
          ..moveTo(46, 64)
          ..quadraticBezierTo(50, 68, 54, 64);
        canvas.drawPath(smile, mouthPaint);
        break;

      case MascotState.thinking:
        // Ojos mirando arriba a la derecha
        canvas.drawCircle(const Offset(43, 54), 2.5, eyePaint);
        canvas.drawCircle(const Offset(61, 54), 2.5, eyePaint);

        // Ceja curiosa arqueada en ojo izquierdo
        final browPaint = Paint()
          ..color = darkEspresso
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawLine(const Offset(38, 49), const Offset(45, 47), browPaint);

        // Boca pensativa en círculo pequeño
        final thinkMouth = Paint()
          ..color = darkEspresso
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(const Offset(50, 66), 2.0, thinkMouth);
        break;

      case MascotState.happy:
        // Ojos en arcos alegres (^ ^)
        final happyEyeLeft = Path()
          ..moveTo(37, 57)
          ..quadraticBezierTo(41, 52, 45, 57);
        final happyEyeRight = Path()
          ..moveTo(55, 57)
          ..quadraticBezierTo(59, 52, 63, 57);
        canvas.drawPath(happyEyeLeft, mouthPaint);
        canvas.drawPath(happyEyeRight, mouthPaint);

        // Gran sonrisa abierta
        final openSmile = Path()
          ..moveTo(43, 62)
          ..quadraticBezierTo(50, 72, 57, 62);
        canvas.drawPath(openSmile, mouthPaint);
        break;

      case MascotState.sad:
        // Ojos caídos
        final sadEyeLeft = Path()
          ..moveTo(38, 55)
          ..quadraticBezierTo(41, 58, 44, 55);
        final sadEyeRight = Path()
          ..moveTo(56, 55)
          ..quadraticBezierTo(59, 58, 62, 55);
        canvas.drawPath(sadEyeLeft, mouthPaint);
        canvas.drawPath(sadEyeRight, mouthPaint);

        // Boca triste invertida
        final sadMouth = Path()
          ..moveTo(45, 68)
          ..quadraticBezierTo(50, 63, 55, 68);
        canvas.drawPath(sadMouth, mouthPaint);
        break;

      case MascotState.celebrate:
        // Ojos guiñando o felices brillantes
        final starEyeLeft = Path()
          ..moveTo(37, 57)
          ..quadraticBezierTo(41, 51, 45, 57);
        canvas.drawPath(starEyeLeft, mouthPaint);
        canvas.drawCircle(const Offset(59, 55), 3.0, eyePaint);

        // Sonrisa de victoria
        final victoryMouth = Path()
          ..moveTo(42, 61)
          ..quadraticBezierTo(50, 73, 58, 61)
          ..close();
        final fillMouth = Paint()
          ..color = const Color(0xFFD9534F)
          ..style = PaintingStyle.fill;
        canvas.drawPath(victoryMouth, fillMouth);
        canvas.drawPath(victoryMouth, mouthPaint);
        break;
    }
  }

  void _drawStateAccessories(Canvas canvas) {
    if (state == MascotState.thinking) {
      // Gota de sudor / concentración en el lateral
      final dropPaint = Paint()
        ..color = dropColor
        ..style = PaintingStyle.fill;
      final dropPath = Path()
        ..moveTo(70, 46)
        ..quadraticBezierTo(72, 42, 74, 46)
        ..quadraticBezierTo(75, 50, 72, 50)
        ..quadraticBezierTo(69, 50, 70, 46);
      canvas.drawPath(dropPath, dropPaint);
    } else if (state == MascotState.celebrate) {
      // Brazos arriba celebrando
      final armPaint = Paint()
        ..color = cupColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      // Brazo izquierdo hacia arriba
      final leftArm = Path()
        ..moveTo(28, 60)
        ..quadraticBezierTo(18, 50, 20, 38);
      canvas.drawPath(leftArm, armPaint);

      // Brazo derecho hacia arriba
      final rightArm = Path()
        ..moveTo(72, 60)
        ..quadraticBezierTo(82, 50, 80, 38);
      canvas.drawPath(rightArm, armPaint);

      // Destellos / Chispas en acento verde y dorado
      _drawSparkle(canvas, 16, 26, accentColor, 4.0);
      _drawSparkle(canvas, 82, 24, const Color(0xFFFFD700), 5.0);
      _drawSparkle(canvas, 50, 10, accentColor, 3.5);
    }
  }

  void _drawSparkle(Canvas canvas, double cx, double cy, Color color, double radius) {
    final sparklePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(cx, cy - radius)
      ..quadraticBezierTo(cx, cy, cx + radius, cy)
      ..quadraticBezierTo(cx, cy, cx, cy + radius)
      ..quadraticBezierTo(cx, cy, cx - radius, cy)
      ..quadraticBezierTo(cx, cy, cx, cy - radius);
    canvas.drawPath(path, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.animationProgress != animationProgress;
  }
}
