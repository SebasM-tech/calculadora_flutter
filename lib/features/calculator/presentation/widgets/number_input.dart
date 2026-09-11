import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';

class NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color accent;

  const NumberInput({
    super.key,
    required this.controller,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 10),
      CupertinoTextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        textAlign: TextAlign.center,
        placeholder: '0',
        cursorColor: accent,
        style: TextStyle(
          fontSize: 32,
          color: accent,
          fontWeight: FontWeight.w500,
        ),
        placeholderStyle: const TextStyle(fontSize: 32, color: AppColors.muted),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: .35)),
        ),
      ),
    ],
  );
}
