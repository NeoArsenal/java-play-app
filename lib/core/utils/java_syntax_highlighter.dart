import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Tokenizador y resaltador sintáctico Java ligero, sin dependencias externas.
/// Colorea palabras clave, anotaciones, strings, números y comentarios
/// garantizando contraste >= 4.5:1 sobre [AppColors.codeBackground].
/// Cuenta con memoización por línea para máximo rendimiento.
class JavaSyntaxHighlighter {
  // Paleta de contraste verificado (> 4.5:1 contra Color(0xFF0F1015))
  static const Color keywordColor = Color(0xFFFF7B72);    // ~7.3:1
  static const Color annotationColor = Color(0xFFFFD166); // ~12.7:1
  static const Color stringColor = Color(0xFF7EE787);     // ~11.5:1
  static const Color numberColor = Color(0xFF79C0FF);     // ~10.2:1
  static const Color commentColor = Color(0xFF8B949E);    // ~6.2:1
  static const Color plainCodeColor = Color(0xFFE6EDF3);  // ~16.0:1

  static final RegExp _tokenizerRegex = RegExp(
    r'(?<comment>//.*|/\*.*?\*/)|'
    r'(?<string>"([^"\\]|\\.)*"|\x27([^\x27\\]|\\.)*\x27)|'
    r'(?<annotation>@\w+)|'
    r'(?<number>\b\d+(\.\d+)?[fFdDlL]?\b)|'
    r'(?<keyword>\b(?:abstract|assert|boolean|break|byte|case|catch|char|class|const|continue|default|do|double|else|enum|extends|final|finally|float|for|goto|if|implements|import|instanceof|int|interface|long|native|new|null|package|private|protected|public|return|short|static|strictfp|super|switch|synchronized|this|throw|throws|transient|try|void|volatile|while|true|false)\b)',
  );

  // Memoización por línea
  static final Map<String, List<TextSpan>> _cache = {};
  static const int _maxCacheSize = 500;

  static void clearCache() {
    _cache.clear();
  }

  /// Calcula la luminancia relativa según estándar WCAG 2.1
  static double calculateLuminance(Color color) {
    double transform(double val) {
      return val <= 0.03928
          ? val / 12.92
          : pow((val + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = transform(color.red / 255.0);
    final g = transform(color.green / 255.0);
    final b = transform(color.blue / 255.0);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calcula la relación de contraste WCAG (ej. 4.5 para 4.5:1)
  static double contrastRatio(Color fg, Color bg) {
    final l1 = calculateLuminance(fg);
    final l2 = calculateLuminance(bg);
    final lighter = max(l1, l2);
    final darker = min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Tokeniza y resalta una línea de código Java
  static List<TextSpan> highlightLine(String line, {TextStyle? baseStyle}) {
    final cached = _cache[line];
    if (cached != null) {
      return cached;
    }

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in _tokenizerRegex.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: line.substring(lastEnd, match.start),
            style: (baseStyle ?? const TextStyle()).copyWith(color: plainCodeColor),
          ),
        );
      }

      Color tokenColor;
      FontWeight tokenWeight = FontWeight.normal;

      if (match.namedGroup('comment') != null) {
        tokenColor = commentColor;
      } else if (match.namedGroup('string') != null) {
        tokenColor = stringColor;
      } else if (match.namedGroup('annotation') != null) {
        tokenColor = annotationColor;
        tokenWeight = FontWeight.bold;
      } else if (match.namedGroup('number') != null) {
        tokenColor = numberColor;
      } else if (match.namedGroup('keyword') != null) {
        tokenColor = keywordColor;
        tokenWeight = FontWeight.bold;
      } else {
        tokenColor = plainCodeColor;
      }

      spans.add(
        TextSpan(
          text: match.group(0),
          style: (baseStyle ?? const TextStyle()).copyWith(
            color: tokenColor,
            fontWeight: tokenWeight,
          ),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      spans.add(
        TextSpan(
          text: line.substring(lastEnd),
          style: (baseStyle ?? const TextStyle()).copyWith(color: plainCodeColor),
        ),
      );
    }

    if (_cache.length >= _maxCacheSize) {
      _cache.clear();
    }
    final result = List<TextSpan>.unmodifiable(spans);
    _cache[line] = result;

    return result;
  }
}
