import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Wraps a horizontally scrollable code block with a subtle right-edge fade gradient
/// and micro-indicator that ONLY displays when there is scrollable content overflowing
/// off-screen to the right.
class HorizontalScrollFadeWrapper extends StatefulWidget {
  final Widget Function(BuildContext context, ScrollController controller) builder;
  final Color fadeColor;
  final BorderRadius? borderRadius;
  final double fadeWidth;

  const HorizontalScrollFadeWrapper({
    super.key,
    required this.builder,
    this.fadeColor = AppColors.codeBackground,
    this.borderRadius,
    this.fadeWidth = 32.0,
  });

  @override
  State<HorizontalScrollFadeWrapper> createState() => _HorizontalScrollFadeWrapperState();
}

class _HorizontalScrollFadeWrapperState extends State<HorizontalScrollFadeWrapper> {
  late final ScrollController _controller = ScrollController();
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_checkScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScroll());
  }

  void _checkScroll() {
    if (!mounted || !_controller.hasClients) return;
    final pos = _controller.position;
    final canScroll = pos.maxScrollExtent > 6 && pos.pixels < (pos.maxScrollExtent - 4);
    if (canScroll != _canScrollRight) {
      setState(() {
        _canScrollRight = canScroll;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_checkScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.horizontal) {
          _checkScroll();
        }
        return false;
      },
      child: Stack(
        children: [
          widget.builder(context, _controller),
          if (_canScrollRight)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: widget.fadeWidth,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        widget.fadeColor.withValues(alpha: 0.0),
                        widget.fadeColor.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: AppColors.textDisabled.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
