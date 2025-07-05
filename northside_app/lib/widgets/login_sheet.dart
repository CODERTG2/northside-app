// lib/widgets/login_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_constants.dart';
import '../core/utils/logger.dart';

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  // Controllers to manage the text in the input fields
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // --- BACKEND INTEGRATION POINT ---
    // Here, you would take the text from the controllers:
    // final email = _emailController.text;
    // final password = _passwordController.text;
    // ...and send it to your backend for authentication.
    
    // For now, we just print and close the sheet.
    AppLogger.debug('Logging in...');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360; // Check for S9 and similar devices
    
    // Get safe area padding to respect notch/status bar
    final EdgeInsets padding = MediaQuery.of(context).padding;
    
    // Adaptive sizing based on screen dimensions
    final double initialChildSize = isNarrowScreen ? 0.85 : 0.9;
    final double minChildSize = isNarrowScreen ? 0.4 : 0.5;
    final double maxChildSize = isNarrowScreen ? 0.85 : 0.9;
    
    return Padding(
      padding: EdgeInsets.only(top: padding.top),
      child: DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        builder: (_, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: true,
              left: false,
              right: false,
              bottom: false,
              child: Column(
                children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: ShapeDecoration(
                  color: Colors.grey.shade300,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: DesignConstants.get10Radius(context),
                      cornerSmoothing: 1.0,
                    ),
                  ),
                ),
              ),
              // Scrollable content area
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    Text(
                      'Link Flex Account',
                      style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    // Email/Username TextField
                    TextField(
                      controller: _emailController,
                      decoration: _inputDecoration('Email or Username'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    // Password TextField
                    TextField(
                      controller: _passwordController,
                      decoration: _inputDecoration('Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    // Log In Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: DesignConstants.get16Radius(context),
                            cornerSmoothing: 1.0,
                          ),
                        ),
                        elevation: 5,
                        shadowColor: Colors.blue.withOpacity(0.4),
                      ),
                      onPressed: _handleLogin,
                      child: const Text('Log In', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
            ),
            ),
          );
        },
      ),
    );
  }

  // Helper method for consistent text field styling
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
