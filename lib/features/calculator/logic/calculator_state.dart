import '../data/models/operation_result.dart';

enum CalculatorStatus { idle, loading, success, error }

class CalculatorState {
  final CalculatorStatus status;
  final double? numberA;
  final double? numberB;
  final List<OperationResult> results;
  final String? parity;
  final String? errorMessage;

  const CalculatorState({
    this.status = CalculatorStatus.idle,
    this.numberA,
    this.numberB,
    this.results = const [],
    this.parity,
    this.errorMessage,
  });

  bool get hasValues => status == CalculatorStatus.success;
}
