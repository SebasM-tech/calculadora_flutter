import 'package:flutter/foundation.dart';

import '../../../core/errors/calculator_exception.dart';
import '../data/models/operation_result.dart';
import '../data/repositories/calculator_repository.dart';
import 'calculator_state.dart';

class CalculatorController extends ChangeNotifier {
  final CalculatorRepository _repository;
  CalculatorState _state = const CalculatorState();
  int _requestId = 0;

  CalculatorController({CalculatorRepository? repository})
    : _repository = repository ?? const CalculatorRepository();

  CalculatorState get state => _state;

  Future<void> calculate(String textA, String textB) async {
    final requestId = ++_requestId;
    if (textA.trim().isEmpty && textB.trim().isEmpty) {
      _setState(const CalculatorState());
      return;
    }

    final a = _parseNumber(textA);
    final b = _parseNumber(textB);
    if (a == null || b == null) {
      final error = CalculatorException.invalidInput();
      _setState(
        CalculatorState(
          status: CalculatorStatus.error,
          errorMessage: error.message,
        ),
      );
      return;
    }

    _setState(
      CalculatorState(status: CalculatorStatus.loading, numberA: a, numberB: b),
    );
    await Future<void>.delayed(Duration.zero);
    if (requestId != _requestId) return;

    try {
      final results = _repository.calculate(a, b);
      _setState(
        CalculatorState(
          status: CalculatorStatus.success,
          numberA: a,
          numberB: b,
          results: results,
          parity: _parity(a, b),
        ),
      );
    } catch (_) {
      const error = CalculatorException(
        CalculatorErrorType.unexpected,
        'No fue posible realizar los cálculos.',
      );
      _setState(
        CalculatorState(
          status: CalculatorStatus.error,
          errorMessage: error.message,
        ),
      );
    }
  }

  List<OperationResult> resultsFor(OperationCategory category) =>
      _state.results.where((result) => result.category == category).toList();

  void clear() {
    _requestId++;
    _setState(const CalculatorState());
  }

  double? _parseNumber(String text) {
    final value = double.tryParse(text.replaceAll(',', '.'));
    return value != null && value.isFinite ? value : null;
  }

  String _parity(double a, double b) {
    if (a % 1 != 0 || b % 1 != 0) {
      return 'La paridad solo aplica a números enteros';
    }
    final aEven = a % 2 == 0;
    final bEven = b % 2 == 0;
    if (aEven && bEven) return 'Ambos son pares';
    if (!aEven && !bEven) return 'Ambos son impares';
    return aEven ? 'A es par y B es impar' : 'A es impar y B es par';
  }

  void _setState(CalculatorState value) {
    _state = value;
    notifyListeners();
  }
}
