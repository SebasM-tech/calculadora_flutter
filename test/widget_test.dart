import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculadora_flutter/app/calculator_app.dart';

Future<void> enterNumbers(WidgetTester tester, String a, String b) async {
  await tester.ensureVisible(find.byType(CupertinoTextField).at(0));
  await tester.enterText(find.byType(CupertinoTextField).at(0), a);
  await tester.enterText(find.byType(CupertinoTextField).at(1), b);
  await tester.pumpAndSettle();
}

void expectResult(String label, String value) {
  final row = find
      .ancestor(of: find.text(label), matching: find.byType(Row))
      .first;
  expect(find.descendant(of: row, matching: find.text(value)), findsOneWidget);
}

void main() {
  testWidgets('Diseno adaptable y boton para reiniciar', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [const Size(360, 800), const Size(1440, 1000)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const CalculatorApp());
      await enterNumbers(tester, '17', '5');
      expectResult('Cociente entero', '3');
      expect(find.text('Ambos son impares'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Empezar de nuevo'));
      await tester.tap(find.text('Empezar de nuevo'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('parity')), findsNothing);
      expect(find.text('Todo está por descubrir'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('Clasifica paridad y rechaza decimales y valores no finitos', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());
    for (final sample in [
      ['0', '-2', 'Ambos son pares'],
      ['-3', '5', 'Ambos son impares'],
      ['2', '3', 'A es par y B es impar'],
      ['3', '2', 'A es impar y B es par'],
      ['2,5', '4', 'La paridad solo aplica a números enteros'],
    ]) {
      await enterNumbers(tester, sample[0], sample[1]);
      expect(find.text(sample[2]), findsOneWidget);
    }
    for (final invalid in ['NaN', 'Infinity', 'abc', '']) {
      await enterNumbers(tester, invalid, '2');
      expect(find.byKey(const ValueKey('parity')), findsNothing);
    }
  });

  testWidgets('Cociente y residuo con signos, decimales y divisor cero', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());
    for (final sample in [
      ['17', '5', '3', '2'],
      ['-17', '5', '-3', '-2'],
      ['17', '-5', '-3', '2'],
      ['-17', '-5', '3', '-2'],
      ['7.5', '2', '3', '1.5'],
      ['0', '5', '0', '0'],
      ['17', '0', '—', '—'],
    ]) {
      await enterNumbers(tester, sample[0], sample[1]);
      expectResult('Cociente entero', sample[2]);
      expectResult('Residuo', sample[3]);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Raices negativas admiten solo indices enteros impares', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.ensureVisible(find.text('Avanzadas'));
    await tester.tap(find.text('Avanzadas'));
    await tester.pumpAndSettle();
    for (final sample in [
      ['-8', '3', '-2'],
      ['-8', '-3', '-0.5'],
      ['-8', '2', '—'],
      ['-8', '2.5', '—'],
      ['-8', '-2.5', '—'],
      ['8', '0', '—'],
      ['16', '2', '4'],
      ['16', '0.5', '256'],
    ]) {
      await enterNumbers(tester, sample[0], sample[1]);
      expectResult('Radicación (ᵇ√a)', sample[2]);
    }
    expect(tester.takeException(), isNull);
  });
}
