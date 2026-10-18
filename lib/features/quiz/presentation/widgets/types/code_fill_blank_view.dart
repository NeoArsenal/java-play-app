import 'package:flutter/material.dart';
import 'package:java_play_app/core/constants/app_colors.dart';
import 'package:java_play_app/core/utils/java_syntax_highlighter.dart';
import 'package:java_play_app/features/quiz/domain/models/exercise.dart';
import '../horizontal_scroll_fade_wrapper.dart';

class CodeFillBlankView extends StatefulWidget {
  final FillBlankExercise exercise;
  final List<String> filledBlanks;
  final List<String> availableOptions;
  final Function(String) onSelectToken;
  final Function(int) onRemoveToken;

  const CodeFillBlankView({
    super.key,
    required this.exercise,
    required this.filledBlanks,
    required this.availableOptions,
    required this.onSelectToken,
    required this.onRemoveToken,
  });

  @override
  State<CodeFillBlankView> createState() => _CodeFillBlankViewState();
}

class _CodeFillBlankViewState extends State<CodeFillBlankView> {
  bool _isWriteMode = false;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitWrittenText() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSelectToken(text);
      _textController.clear();
      _focusNode.unfocus();
    }
  }

  Widget _buildBlankSlot(int blankIndex) {
    final isFilled = blankIndex < widget.filledBlanks.length;
    if (isFilled) {
      return InkWell(
        onTap: () => widget.onRemoveToken(blankIndex),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryGreen, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.filledBlanks[blankIndex],
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.close_rounded, size: 14, color: AppColors.primaryGreen),
            ],
          ),
        ),
      );
    } else {
      final isNextToFill = blankIndex == widget.filledBlanks.length;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isNextToFill ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isNextToFill ? AppColors.duolingoOrange : AppColors.textDisabled,
            width: isNextToFill ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          "____",
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isNextToFill ? AppColors.duolingoOrange : AppColors.textDisabled,
          ),
        ),
      );
    }
  }

  Widget _buildCodeTemplateContent(TextScaler textScaler) {
    final rawLines = widget.exercise.codeTemplate.split('\n');
    int effectiveCount = rawLines.length;
    while (effectiveCount > 0 && rawLines[effectiveCount - 1].trim().isEmpty) {
      effectiveCount--;
    }
    final lines = rawLines.sublist(0, effectiveCount);

    final blankRegex = RegExp(r'_{2,}');
    int blankCounter = 0;
    const double rowHeight = 44.0;
    const double gutterWidth = 44.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final codeViewportWidth = (constraints.maxWidth - gutterWidth).clamp(0.0, double.infinity);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed Left Gutter (Line Numbers)
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
                children: List.generate(lines.length, (index) {
                  return Container(
                    height: rowHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: index < lines.length - 1
                              ? AppColors.codeBorder.withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Text(
                      "${index + 1}",
                      textScaler: textScaler,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppColors.textDisabled,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Horizontally Scrollable Code Content
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
                        children: lines.asMap().entries.map((entry) {
                          final lineIndex = entry.key;
                          final line = entry.value;
                          final parts = line.split(blankRegex);

                          final lineSpans = <Widget>[];
                          for (int p = 0; p < parts.length; p++) {
                            if (parts[p].isNotEmpty) {
                              lineSpans.add(
                                Text.rich(
                                  TextSpan(
                                    children: JavaSyntaxHighlighter.highlightLine(
                                      parts[p],
                                      baseStyle: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 13.5,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  softWrap: false,
                                  textScaler: textScaler,
                                ),
                              );
                            }
                            if (p < parts.length - 1) {
                              final bIndex = blankCounter;
                              blankCounter++;
                              lineSpans.add(
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _buildBlankSlot(bIndex),
                                ),
                              );
                            }
                          }

                          return Container(
                            height: rowHeight,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: lineIndex < lines.length - 1
                                      ? AppColors.codeBorder.withValues(alpha: 0.4)
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: lineSpans,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                "COMPLETA EL CÓDIGO FALTANTE",
                style: TextStyle(
                  color: AppColors.duolingoOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Text(
                "DINÁMICA JAVA",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.exercise.question,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),

        // Code Editor Box
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mac-style window header bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF161F2B),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: Row(
                    children: [
                      Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      const Flexible(
                        child: Text(
                          "Editor Java - Completa los espacios",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.textDisabled, fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
                // Code Content with fixed gutter and scrollable code
                _buildCodeTemplateContent(textScaler),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Dual Mode Switcher
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isWriteMode = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !_isWriteMode ? AppColors.codeBackground : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: !_isWriteMode ? AppColors.primaryGreen : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          size: 15,
                          color: !_isWriteMode ? AppColors.primaryGreen : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "Opciones (Tokens)",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: !_isWriteMode ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isWriteMode = true);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) _focusNode.requestFocus();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _isWriteMode ? AppColors.codeBackground : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isWriteMode ? AppColors.duolingoOrange : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.keyboard,
                          size: 16,
                          color: _isWriteMode ? AppColors.duolingoOrange : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "Escribir código",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isWriteMode ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Mode content
        if (!_isWriteMode) ...[
          const Text(
            "Toca una opción para insertarla en el código:",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.availableOptions.map((token) {
              return ActionChip(
                label: Text(
                  token,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.surfaceBorder, width: 1.5),
                ),
                onPressed: () => widget.onSelectToken(token),
              );
            }).toList(),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, color: AppColors.duolingoOrange, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "¿Estás confiado? Escribe la palabra exacta:",
                      style: TextStyle(
                        color: AppColors.duolingoOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: "Ej: static, valueOf, new...",
                          hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
                          filled: true,
                          fillColor: AppColors.codeBackground,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.surfaceBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.surfaceBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.duolingoOrange, width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _submitWrittenText(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.duolingoOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _submitWrittenText,
                      child: const Text("Insertar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

