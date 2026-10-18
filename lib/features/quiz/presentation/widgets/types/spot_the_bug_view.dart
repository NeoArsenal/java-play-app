import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:java_play_app/core/constants/app_colors.dart';
import 'package:java_play_app/core/utils/java_syntax_highlighter.dart';
import 'package:java_play_app/features/quiz/domain/models/exercise.dart';
import 'package:java_play_app/features/quiz/presentation/controllers/quiz_controller.dart';
import '../horizontal_scroll_fade_wrapper.dart';

class SpotTheBugView extends StatelessWidget {
  final SpotTheBugExercise exercise;
  final int? selectedLineIndex;
  final ValueChanged<int> onSelectLine;
  final AnswerStatus answerStatus;

  const SpotTheBugView({
    super.key,
    required this.exercise,
    required this.selectedLineIndex,
    required this.onSelectLine,
    this.answerStatus = AnswerStatus.unselected,
  });

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);
    final isAnswered = answerStatus == AnswerStatus.correct || answerStatus == AnswerStatus.incorrect;

    // Filter trailing empty lines from rendering, preserving 0-based indices for all visible lines
    int effectiveCount = exercise.codeLines.length;
    while (effectiveCount > 0 && exercise.codeLines[effectiveCount - 1].trim().isEmpty) {
      effectiveCount--;
    }

    const double rowHeight = 44.0;
    const double gutterWidth = 44.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                "ENCUENTRA EL ERROR",
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.5)),
              ),
              child: const Text(
                "1 FALLO OCULTO",
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          exercise.question,
          textScaler: textScaler,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),

        // Code Editor Box with Fixed Gutter and Horizontal Scrolling Code
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.codeBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.codeBorder, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final codeViewportWidth = (constraints.maxWidth - gutterWidth).clamp(0.0, double.infinity);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Fixed Left Gutter (Line Numbers)
                    Container(
                      width: gutterWidth,
                      decoration: const BoxDecoration(
                        color: Color(0xFF161F2B),
                        border: Border(
                          right: BorderSide(color: Color(0xFF243042), width: 1.5),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(effectiveCount, (index) {
                          final isSelected = selectedLineIndex == index;
                          final isCorrectLine = index == exercise.buggyLineIndex;

                          Color gutterNumColor = AppColors.textDisabled;
                          Color gutterBg = Colors.transparent;

                          if (!isAnswered) {
                            if (isSelected) {
                              gutterNumColor = Colors.white;
                              gutterBg = const Color(0xFF1E3A5F).withValues(alpha: 0.5);
                            }
                          } else {
                            if (isCorrectLine) {
                              gutterNumColor = Colors.white;
                              gutterBg = AppColors.primaryGreen.withValues(alpha: 0.35);
                            } else if (isSelected) {
                              gutterNumColor = Colors.white;
                              gutterBg = AppColors.errorRed.withValues(alpha: 0.35);
                            }
                          }

                          return InkWell(
                            onTap: isAnswered
                                ? null
                                : () {
                                    HapticFeedback.selectionClick();
                                    onSelectLine(index);
                                  },
                            child: Container(
                              height: rowHeight,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: gutterBg,
                                border: Border(
                                  bottom: BorderSide(
                                    color: index < effectiveCount - 1
                                        ? AppColors.codeBorder.withValues(alpha: 0.4)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                              child: Text(
                                "${index + 1}",
                                textScaler: textScaler,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: gutterNumColor,
                                  fontWeight: isSelected || (isAnswered && isCorrectLine)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // 2. Horizontally Scrollable Code Content (offset starting at 0)
                    Expanded(
                      child: HorizontalScrollFadeWrapper(
                        fadeColor: AppColors.codeBackground,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        builder: (context, controller) {
                          return SingleChildScrollView(
                            controller: controller,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: codeViewportWidth),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(effectiveCount, (index) {
                                  final isSelected = selectedLineIndex == index;
                                  final isCorrectLine = index == exercise.buggyLineIndex;

                                  Color rowColor = Colors.transparent;
                                  Color borderIndicator = Colors.transparent;
                                  Color codeTextColor = AppColors.codeText;
                                  FontWeight codeWeight = FontWeight.normal;
                                  IconData? rowIcon;
                                  Color iconColor = Colors.transparent;

                                  if (!isAnswered) {
                                    if (isSelected) {
                                      rowColor = const Color(0xFF1E3A5F).withValues(alpha: 0.35);
                                      borderIndicator = const Color(0xFF3892F6);
                                      codeTextColor = Colors.white;
                                      codeWeight = FontWeight.bold;
                                      rowIcon = Icons.error_outline_rounded;
                                      iconColor = const Color(0xFF3892F6);
                                    }
                                  } else {
                                    if (isCorrectLine) {
                                      // Correct line is highlighted green
                                      rowColor = AppColors.primaryGreen.withValues(alpha: 0.22);
                                      borderIndicator = AppColors.primaryGreen;
                                      codeTextColor = const Color(0xFFD4FFD8);
                                      codeWeight = FontWeight.bold;
                                      rowIcon = Icons.check_circle_rounded;
                                      iconColor = AppColors.primaryGreen;
                                    } else if (isSelected) {
                                      // User selected wrong line -> RED
                                      rowColor = AppColors.errorRed.withValues(alpha: 0.22);
                                      borderIndicator = AppColors.errorRed;
                                      codeTextColor = const Color(0xFFFFD4D4);
                                      codeWeight = FontWeight.bold;
                                      rowIcon = Icons.cancel_rounded;
                                      iconColor = AppColors.errorRed;
                                    } else {
                                      codeTextColor = AppColors.textDisabled;
                                    }
                                  }

                                  return InkWell(
                                    onTap: isAnswered
                                        ? null
                                        : () {
                                            HapticFeedback.selectionClick();
                                            onSelectLine(index);
                                          },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      height: rowHeight,
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: rowColor,
                                        border: Border(
                                          left: BorderSide(
                                            color: borderIndicator,
                                            width: 4,
                                          ),
                                          bottom: BorderSide(
                                            color: index < effectiveCount - 1
                                                ? AppColors.codeBorder.withValues(alpha: 0.4)
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!isSelected && (!isAnswered || !isCorrectLine)) ...[
                                            Text.rich(
                                              TextSpan(
                                                children: JavaSyntaxHighlighter.highlightLine(
                                                  exercise.codeLines[index],
                                                  baseStyle: TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 13.5,
                                                    color: isAnswered ? AppColors.textDisabled : null,
                                                  ),
                                                ),
                                              ),
                                              softWrap: false,
                                              textScaler: textScaler,
                                            ),
                                          ] else ...[
                                            Text(
                                              exercise.codeLines[index],
                                              softWrap: false,
                                              textScaler: textScaler,
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 13.5,
                                                color: codeTextColor,
                                                fontWeight: codeWeight,
                                              ),
                                            ),
                                          ],
                                          if (rowIcon != null) ...[
                                            const SizedBox(width: 14),
                                            Icon(
                                              rowIcon,
                                              color: iconColor,
                                              size: 18,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
