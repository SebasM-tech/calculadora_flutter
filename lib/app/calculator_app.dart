import 'package:flutter/cupertino.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/calculator/presentation/pages/calculator_page.dart';

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) => const CupertinoApp(
    title: AppConstants.appTitle,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.cupertino,
    home: CalculatorPage(),
  );
}
