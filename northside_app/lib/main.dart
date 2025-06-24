// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'core/theme/app_theme.dart'; // Import the new theme
import 'presentation/app_shell/app_shell_binding.dart';
import 'presentation/app_shell/app_shell_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Northside App',

          // FIX: Apply our new custom theme to the entire app.
          theme: AppTheme.lightTheme,

          initialBinding: AppShellBinding(),
          home: const AppShellScreen(),
        );
      },
    );
  }
}
