import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_employee_management/core/themes/app_theme.dart';
import 'package:ai_employee_management/core/themes/app_colors.dart';

void main() {
  group('App Theme Validation Tests', () {
    test('Verify light and dark theme configurations load correctly', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);

      expect(AppColors.indigoAccent, const Color(0xFF536DFE));
      expect(lightTheme.cardTheme.elevation, 0);
      expect(darkTheme.cardTheme.elevation, 0);
    });
  });
}
