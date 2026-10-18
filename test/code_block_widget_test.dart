import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:java_play_app/core/constants/app_colors.dart';
import 'package:java_play_app/features/quiz/domain/models/exercise.dart';
import 'package:java_play_app/features/quiz/presentation/controllers/quiz_controller.dart';
import 'package:java_play_app/features/quiz/presentation/widgets/types/spot_the_bug_view.dart';
import 'package:java_play_app/features/quiz/presentation/widgets/types/code_fill_blank_view.dart';

void main() {
  const bugExerciseWithTrailingBlank = SpotTheBugExercise(
    id: 'test_bug_billetera',
    question: 'Encuentra el error:',
    codeLines: [
      'public class Billetera {',
      '    public double saldo;',
      '    public Billetera(double saldo) { this.saldo = saldo; }',
      '}',
      '',
      '   ',
    ],
    buggyLineIndex: 1,
    explanation: 'Violación de encapsulamiento.',
  );

  testWidgets('SpotTheBugView: números de línea fijos, primer carácter visible y línea vacía final excluida', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    int? selectedLine;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SpotTheBugView(
              exercise: bugExerciseWithTrailingBlank,
              selectedLineIndex: selectedLine,
              onSelectLine: (index) {
                selectedLine = index;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Líneas vacías al final no se renderizan (tenía 6 líneas, las 2 últimas vacías; quedan 4)
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5'), findsNothing, reason: 'Línea vacía final no debe renderizarse');
    expect(find.text('6'), findsNothing, reason: 'Línea vacía final no debe renderizarse');

    // 2. Primer carácter visible al inicio (offset 0)
    final line1Finder = find.text('public class Billetera {');
    expect(line1Finder, findsOneWidget);
    final line1InitialPos = tester.getTopLeft(line1Finder);
    // Gutter width is 44 + padding (20) + inner margin (14) = ~78. It must be inside visible viewport (> 44, < 360)
    expect(line1InitialPos.dx, greaterThan(44.0));
    expect(line1InitialPos.dx, lessThan(120.0));

    // 3. Números de línea fijos al hacer scroll horizontal
    final lineNum1PosBefore = tester.getTopLeft(find.text('1'));
    final scrollable = find.byType(SingleChildScrollView);
    expect(scrollable, findsOneWidget);

    await tester.drag(scrollable, const Offset(-100, 0));
    await tester.pumpAndSettle();

    final lineNum1PosAfter = tester.getTopLeft(find.text('1'));
    expect(lineNum1PosAfter.dx, equals(lineNum1PosBefore.dx),
        reason: 'Los números de línea deben permanecer fijos y no desplazarse');

    // 4. Altura táctil mínima de 44 px por fila
    final gutter1 = tester.getSize(find.ancestor(of: find.text('1'), matching: find.byType(InkWell)).first);
    expect(gutter1.height, greaterThanOrEqualTo(44.0));

    // 5. Preservar mapeo de índices con buggyLineIndex (tocar fila 2 = index 1)
    await tester.tap(find.ancestor(of: find.text('2'), matching: find.byType(InkWell)).first);
    expect(selectedLine, equals(1));
  });

  testWidgets('SpotTheBugView: estados de fila (neutro antes de comprobar, verde/rojo tras comprobar)', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Estado 1: Seleccionada la línea 0 antes de comprobar
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpotTheBugView(
            exercise: bugExerciseWithTrailingBlank,
            selectedLineIndex: 0,
            onSelectLine: (_) {},
            answerStatus: AnswerStatus.readyToVerify,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Ícono de selección neutra (error_outline_rounded)
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

    // Estado 2: Comprobado y fallido (seleccionó 0, pero la correcta era 1)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpotTheBugView(
            exercise: bugExerciseWithTrailingBlank,
            selectedLineIndex: 0,
            onSelectLine: (_) {},
            answerStatus: AnswerStatus.incorrect,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Debe mostrar cancel_rounded (rojo/fallo en fila seleccionada) y check_circle_rounded (verde en fila correcta)
    expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Estado 3: Comprobado y acertado (seleccionó 1)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpotTheBugView(
            exercise: bugExerciseWithTrailingBlank,
            selectedLineIndex: 1,
            onSelectLine: (_) {},
            answerStatus: AnswerStatus.correct,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.byIcon(Icons.cancel_rounded), findsNothing);
  });

  testWidgets('CodeFillBlankView: columna fija y scroll horizontal independiente', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const fillBlankExercise = FillBlankExercise(
      id: 'test_fill_blank',
      question: 'Completa el código:',
      codeTemplate: 'public class Animal {\n    public void hacerSonido() {\n        System.out.println("Sonido largo de más de sesenta caracteres para provocar scroll horizontal");\n    }\n}\n\n',
      correctAnswers: ['Animal'],
      options: ['Animal', 'Perro', 'Gato'],
      explanation: 'Clase animal.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CodeFillBlankView(
              exercise: fillBlankExercise,
              availableOptions: const ['Animal', 'Perro', 'Gato'],
              filledBlanks: const ['Animal'],
              onSelectToken: (_) {},
              onRemoveToken: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Líneas vacías finales ignoradas: tenía 7 líneas (5 con código, 2 vacías al final)
    expect(find.text('1'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('6'), findsNothing);
    expect(find.text('7'), findsNothing);

    // Número de línea fijo
    final lineNum1PosBefore = tester.getTopLeft(find.text('1'));
    final scrollables = find.byType(SingleChildScrollView);
    // Find the horizontal one
    final horizontalScrollable = scrollables.at(1);

    await tester.drag(horizontalScrollable, const Offset(-100, 0));
    await tester.pumpAndSettle();

    final lineNum1PosAfter = tester.getTopLeft(find.text('1'));
    expect(lineNum1PosAfter.dx, equals(lineNum1PosBefore.dx));
  });
}
