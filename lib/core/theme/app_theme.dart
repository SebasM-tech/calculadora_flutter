import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const cupertino = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.mint,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        color: AppColors.white,
        fontFamily: 'sans-serif',
        fontSize: 15,
      ),
    ),
  );
}
