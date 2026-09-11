import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/operation_result.dart';

class ResultCard extends StatelessWidget {
  final OperationResult result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final accent = result.category == OperationCategory.advanced
        ? AppColors.violet
        : AppColors.mint;
    final formattedValue = formatResult(result.value);
    return Container(
      key: ValueKey('result-${result.name}'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconFor(result.type), size: 18, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.name,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: Duration(
                    milliseconds: MediaQuery.of(context).disableAnimations
                        ? 0
                        : 180,
                  ),
                  child: SizedBox(
                    key: ValueKey(formattedValue),
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formattedValue,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w500,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(OperationType type) => switch (type) {
    OperationType.addition => CupertinoIcons.plus,
    OperationType.subtraction => CupertinoIcons.minus,
    OperationType.multiplication => CupertinoIcons.multiply,
    OperationType.division ||
    OperationType.integerQuotient => CupertinoIcons.divide,
    OperationType.remainder || OperationType.modulo => CupertinoIcons.percent,
    OperationType.power => CupertinoIcons.arrow_up,
    OperationType.root => CupertinoIcons.arrow_down,
    OperationType.logarithm => CupertinoIcons.chart_bar,
  };
}

String formatResult(double? value) {
  if (value == null || !value.isFinite) return '—';
  if (value == 0) return '0';
  if (value.abs() >= 1e12 || value.abs() < 1e-6) {
    return value.toStringAsExponential(4);
  }
  return value.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
}
