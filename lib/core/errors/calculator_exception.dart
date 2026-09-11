enum CalculatorErrorType { invalidInput, unexpected }

class CalculatorException implements Exception {
  final CalculatorErrorType type;
  final String message;

  const CalculatorException(this.type, this.message);

  factory CalculatorException.invalidInput() => const CalculatorException(
    CalculatorErrorType.invalidInput,
    'Ingresa dos números válidos para continuar.',
  );
}
