import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/feedback_settings.dart';

/// Estados visuales del enemigo "Bug" (el bicho pixelado de errores de código).
enum BugEnemyState {
  appear,
  glitch,
  defeated,
}

/// Widget que representa al enemigo Bug con estética pixelada 8-bit.
/// Utiliza CustomPaint y efectos de desplazamiento de color (glitch sin shaders)
/// respetando animaciones reducidas para accesibilidad.
class BugEnemyWidget extends StatefulWidget {
  final BugEnemyState state;
  final double size;
  final VoidCallback? onDefeatedComplete;

  const BugEnemyWidget({
    super.key,
    required this.state,
    this.size = 72.0,
    this.onDefeatedComplete,
  });

  @override
  State<BugEnemyWidget> createState() => _BugEnemyWidgetState();
}

class _BugEnemyWidgetState extends State<BugEnemyWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant BugEnemyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    final reduced = FeedbackSettings.isReducedMotion(context);
    if (reduced) {
      _controller.stop();
      _controller.value = 1.0;
      return;
    }

    switch (widget.state) {
      case BugEnemyState.appear:
        _controller.repeat(reverse: true);
        break;
      case BugEnemyState.glitch:
        _controller.repeat();
        break;
      case BugEnemyState.defeated:
        _controller.forward(from: 0.0).then((_) {
          widget.onDefeatedComplete?.call();
        });
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _semanticsLabel {
    switch (widget.state) {
      case BugEnemyState.appear:
        return 'Un bug de software ha aparecido';
      case BugEnemyState.glitch:
        return 'El bug de código está sufriendo un glitch';
      case BugEnemyState.defeated:
        return 'El bug de software ha sido derrotado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduced = FeedbackSettings.isReducedMotion(context);

    if (reduced) {
      if (widget.state == BugEnemyState.defeated) {
        return const SizedBox.shrink();
      }
      return Semantics(
        label: _semanticsLabel,
        image: true,
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _PixelBugPainter(
              isGlitch: false,
              isDefeated: false,
              progress: 0.0,
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: _semanticsLabel,
      image: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;

            if (widget.state == BugEnemyState.defeated) {
              final scale = (1.0 - progress).clamp(0.0, 1.0);
              final opacity = (1.0 - progress).clamp(0.0, 1.0);
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _PixelBugPainter(
                      isGlitch: false,
                      isDefeated: true,
                      progress: progress,
                    ),
                  ),
                ),
              );
            }

            if (widget.state == BugEnemyState.glitch) {
              // Efecto glitch: jitter de traslación y separación cromática sin shaders
              final jitterX = (math.sin(progress * 40) * 3.5).roundToDouble();
              final jitterY = (math.cos(progress * 25) * 1.5).roundToDouble();

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Capa cian desplazada a la izquierda
                  Transform.translate(
                    offset: Offset(jitterX - 2.0, jitterY),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF00FFFF),
                        BlendMode.srcATop,
                      ),
                      child: Opacity(
                        opacity: 0.5,
                        child: CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: _PixelBugPainter(
                            isGlitch: true,
                            isDefeated: false,
                            progress: progress,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Capa magenta desplazada a la derecha
                  Transform.translate(
                    offset: Offset(jitterX + 2.0, jitterY),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFFF0055),
                        BlendMode.srcATop,
                      ),
                      child: Opacity(
                        opacity: 0.5,
                        child: CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: _PixelBugPainter(
                            isGlitch: true,
                            isDefeated: false,
                            progress: progress,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Cuerpo principal
                  Transform.translate(
                    offset: Offset(jitterX, jitterY),
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _PixelBugPainter(
                        isGlitch: true,
                        isDefeated: false,
                        progress: progress,
                      ),
                    ),
                  ),
                ],
              );
            }

            // Estado appear: respiración sutil
            final breathe = 1.0 + (math.sin(progress * math.pi) * 0.05);
            return Transform.scale(
              scale: breathe,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _PixelBugPainter(
                  isGlitch: false,
                  isDefeated: false,
                  progress: progress,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PixelBugPainter extends CustomPainter {
  final bool isGlitch;
  final bool isDefeated;
  final double progress;

  _PixelBugPainter({
    required this.isGlitch,
    required this.isDefeated,
    required this.progress,
  });

  // Matriz de píxeles 12x12 que dibuja el bicho estilo retro arcade
  // 0: vacío, 1: caparazón morado, 2: ojos rojos/amarillos, 3: patas/antenas
  static const List<List<int>> _pixelGrid = [
    [0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0],
    [0, 0, 3, 0, 0, 0, 0, 0, 0, 3, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [3, 0, 1, 2, 1, 1, 1, 1, 2, 1, 0, 3],
    [3, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1, 3],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [3, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 3],
    [3, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 3],
    [0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0],
    [3, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 3],
    [0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const gridCols = 12;
    const gridRows = 12;
    final pixelWidth = size.width / gridCols;
    final pixelHeight = size.height / gridRows;

    final shellPaint = Paint()
      ..color = isGlitch ? const Color(0xFF9333EA) : const Color(0xFF6B21A8)
      ..style = PaintingStyle.fill;

    final eyePaint = Paint()
      ..color = isDefeated
          ? const Color(0xFF475569)
          : (isGlitch ? const Color(0xFFFFCC00) : const Color(0xFFEF4444))
      ..style = PaintingStyle.fill;

    final legPaint = Paint()
      ..color = const Color(0xFF3B0764)
      ..style = PaintingStyle.fill;

    for (int r = 0; r < gridRows; r++) {
      for (int c = 0; c < gridCols; c++) {
        final val = _pixelGrid[r][c];
        if (val == 0) continue;

        Paint paint;
        if (val == 1) {
          paint = shellPaint;
        } else if (val == 2) {
          paint = eyePaint;
        } else {
          paint = legPaint;
        }

        final rect = Rect.fromLTWH(
          c * pixelWidth,
          r * pixelHeight,
          pixelWidth,
          pixelHeight,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelBugPainter oldDelegate) {
    return oldDelegate.isGlitch != isGlitch ||
        oldDelegate.isDefeated != isDefeated ||
        oldDelegate.progress != progress;
  }
}
