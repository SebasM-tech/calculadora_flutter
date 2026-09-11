import 'dart:math';

import '../models/operation_result.dart';

class CalculatorRepository {
  const CalculatorRepository();

  List<OperationResult> calculate(double a, double b) => [
    _result(OperationType.addition, 'Suma', a + b),
    _result(OperationType.subtraction, 'Resta', a - b),
    _result(OperationType.multiplication, 'Multiplicación', a * b),
    _result(OperationType.division, 'División', b != 0 ? a / b : null),
    _result(
      OperationType.integerQuotient,
      'Cociente entero',
      b != 0 && (a / b).isFinite ? (a / b).truncateToDouble() : null,
    ),
    _result(OperationType.remainder, 'Residuo', b != 0 ? a.remainder(b) : null),
    _result(OperationType.modulo, 'Módulo', b != 0 ? a % b : null),
    _result(
      OperationType.power,
      'Potenciación (aᵇ)',
      pow(a, b).toDouble(),
      category: OperationCategory.advanced,
    ),
    _result(
      OperationType.root,
      'Radicación (ᵇ√a)',
      _nthRoot(a, b),
      category: OperationCategory.advanced,
    ),
    _result(
      OperationType.logarithm,
      'Logaritmación (log_b a)',
      a > 0 && b > 0 && b != 1 ? log(a) / log(b) : null,
      category: OperationCategory.advanced,
    ),
  ];

  OperationResult _result(
    OperationType type,
    String name,
    double? value, {
    OperationCategory category = OperationCategory.basic,
  }) =>
      OperationResult(type: type, name: name, value: value, category: category);

  double? _nthRoot(double value, double index) {
    if (index == 0) return null;
    if (value < 0) {
      if (index % 1 != 0 || index % 2 == 0) return null;
      return -pow(-value, 1 / index).toDouble();
    }
    return pow(value, 1 / index).toDouble();
  }
}
