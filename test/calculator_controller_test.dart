import 'package:calculadora_flutter/features/calculator/logic/calculator_controller.dart';
import 'package:calculadora_flutter/features/calculator/logic/calculator_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorController', () {
    test('pasa por carga y entrega los resultados', () async {
      final controller = CalculatorController();

      final calculation = controller.calculate('17', '5');
      expect(controller.state.status, CalculatorStatus.loading);

      await calculation;
      expect(controller.state.status, CalculatorStatus.success);
      expect(controller.state.parity, 'Ambos son impares');
      expect(controller.state.results, hasLength(10));

      controller.dispose();
    });

    test('informa un error cuando la entrada no es válida', () async {
      final controller = CalculatorController();

      await controller.calculate('abc', '5');

      expect(controller.state.status, CalculatorStatus.error);
      expect(controller.state.errorMessage, isNotEmpty);
      expect(controller.state.results, isEmpty);

      controller.dispose();
    });

    test('regresa al estado inicial al limpiar', () async {
      final controller = CalculatorController();
      await controller.calculate('8', '2');

      controller.clear();

      expect(controller.state.status, CalculatorStatus.idle);
      expect(controller.state.results, isEmpty);
      controller.dispose();
    });
  });
}
