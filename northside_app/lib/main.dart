// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'core/theme/app_theme.dart'; // Import the new theme
import 'presentation/app_shell/app_shell_binding.dart';
import 'presentation/app_shell/app_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Ensure text scaling doesn't break layouts on S9 and other devices
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

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
          title: 'Stampede',

          // FIX: Apply our new custom theme to the entire app.
          theme: AppTheme.lightTheme,

          initialBinding: AppShellBinding(),
          home: const AppShellScreen(),

          // Add this builder to prevent system text scaling from breaking layouts
          builder: (context, child) {
            // Force a specific text scale factor to prevent text overflow
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0, // Fixed text scale factor
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
