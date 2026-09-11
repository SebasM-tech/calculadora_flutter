enum OperationCategory { basic, advanced }

enum OperationType {
  addition,
  subtraction,
  multiplication,
  division,
  integerQuotient,
  remainder,
  modulo,
  power,
  root,
  logarithm,
}

class OperationResult {
  final OperationType type;
  final String name;
  final double? value;
  final OperationCategory category;

  const OperationResult({
    required this.type,
    required this.name,
    required this.value,
    required this.category,
  });
}
