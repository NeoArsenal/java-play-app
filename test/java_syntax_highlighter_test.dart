import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:java_play_app/core/constants/app_colors.dart';
import 'package:java_play_app/core/utils/java_syntax_highlighter.dart';

void main() {
  group('JavaSyntaxHighlighter Tests', () {
    test('Tokeniza palabras clave, anotaciones, strings, números y comentarios', () {
      JavaSyntaxHighlighter.clearCache();
      const line = '@Override public void test() { int x = 42; String s = "hola"; // comment }';
      final spans = JavaSyntaxHighlighter.highlightLine(line);

      // Verificamos presencia de tokens coloreados
      final texts = spans.map((s) => s.text).toList();
      expect(texts.contains('@Override'), isTrue);
      expect(texts.contains('public'), isTrue);
      expect(texts.contains('void'), isTrue);
      expect(texts.contains('int'), isTrue);
      expect(texts.contains('42'), isTrue);
      expect(texts.contains('"hola"'), isTrue);
      expect(texts.contains('// comment }'), isTrue);

      // Verificamos los estilos aplicados
      final overrideSpan = spans.firstWhere((s) => s.text == '@Override');
      expect(overrideSpan.style?.color, equals(JavaSyntaxHighlighter.annotationColor));

      final publicSpan = spans.firstWhere((s) => s.text == 'public');
      expect(publicSpan.style?.color, equals(JavaSyntaxHighlighter.keywordColor));

      final numberSpan = spans.firstWhere((s) => s.text == '42');
      expect(numberSpan.style?.color, equals(JavaSyntaxHighlighter.numberColor));

      final stringSpan = spans.firstWhere((s) => s.text == '"hola"');
      expect(stringSpan.style?.color, equals(JavaSyntaxHighlighter.stringColor));

      final commentSpan = spans.firstWhere((s) => s.text == '// comment }');
      expect(commentSpan.style?.color, equals(JavaSyntaxHighlighter.commentColor));
    });

    test('Contraste mínimo 4.5:1 sobre AppColors.codeBackground para todos los colores', () {
      const bg = AppColors.codeBackground; // Color(0xFF0F1015)

      final keywordRatio = JavaSyntaxHighlighter.contrastRatio(JavaSyntaxHighlighter.keywordColor, bg);
      final annotationRatio = JavaSyntaxHighlighter.contrastRatio(JavaSyntaxHighlighter.annotationColor, bg);
      final stringRatio = JavaSyntaxHighlighter.contrastRatio(JavaSyntaxHighlighter.stringColor, bg);
      final numberRatio = JavaSyntaxHighlighter.contrastRatio(JavaSyntaxHighlighter.numberColor, bg);
      final commentRatio = JavaSyntaxHighlighter.contrastRatio(JavaSyntaxHighlighter.commentColor, bg);
      final plainRatio = JavaSyntaxHighlighter.contrastRatio(JavaSyntaxHighlighter.plainCodeColor, bg);

      expect(keywordRatio, greaterThanOrEqualTo(4.5), reason: 'Keyword contrast $keywordRatio must be >= 4.5');
      expect(annotationRatio, greaterThanOrEqualTo(4.5), reason: 'Annotation contrast $annotationRatio must be >= 4.5');
      expect(stringRatio, greaterThanOrEqualTo(4.5), reason: 'String contrast $stringRatio must be >= 4.5');
      expect(numberRatio, greaterThanOrEqualTo(4.5), reason: 'Number contrast $numberRatio must be >= 4.5');
      expect(commentRatio, greaterThanOrEqualTo(4.5), reason: 'Comment contrast $commentRatio must be >= 4.5');
      expect(plainRatio, greaterThanOrEqualTo(4.5), reason: 'Plain contrast $plainRatio must be >= 4.5');
    });

    test('Memoización: llamadas sucesivas con la misma línea retornan la misma instancia en caché', () {
      JavaSyntaxHighlighter.clearCache();
      const line = 'public class Perro extends Animal {';
      final first = JavaSyntaxHighlighter.highlightLine(line);
      final second = JavaSyntaxHighlighter.highlightLine(line);

      expect(identical(first, second), isTrue);
    });
  });
}
