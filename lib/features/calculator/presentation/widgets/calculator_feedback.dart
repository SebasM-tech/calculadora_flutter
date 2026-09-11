import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import 'background_painters.dart';

class EmptyResults extends StatelessWidget {
  const EmptyResults({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 24),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.line),
      borderRadius: BorderRadius.circular(24),
      color: AppColors.panel.withValues(alpha: .45),
    ),
    child: const Column(
      children: [
        SizedBox(
          width: 150,
          height: 100,
          child: CustomPaint(painter: OrbitPainter()),
        ),
        SizedBox(height: 24),
        Text(
          'Todo está por descubrir',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        Text(
          'Ingresa ambos números\npara ver los resultados',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, height: 1.6, fontSize: 14),
        ),
      ],
    ),
  );
}

class LoadingResults extends StatelessWidget {
  const LoadingResults({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 180,
    child: Center(
      child: CupertinoActivityIndicator(color: AppColors.mint, radius: 14),
    ),
  );
}

class ErrorResults extends StatelessWidget {
  final String message;

  const ErrorResults({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: CupertinoColors.systemRed.withValues(alpha: .08),
      border: Border.all(
        color: CupertinoColors.systemRed.withValues(alpha: .35),
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        const Icon(
          CupertinoIcons.exclamationmark_triangle,
          color: CupertinoColors.systemRed,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    ),
  );
}
