import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';

class CalculatorPanel extends StatelessWidget {
  final Widget child;

  const CalculatorPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF16243A), Color(0xFF101A2C)],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.line),
      boxShadow: [
        BoxShadow(
          color: CupertinoColors.black.withValues(alpha: .15),
          blurRadius: 30,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: child,
  );
}
