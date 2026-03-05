import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Color(0xFF7B9E87); // 차분한 그린

  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );
}
