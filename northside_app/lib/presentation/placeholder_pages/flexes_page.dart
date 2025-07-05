// lib/presentation/placeholder_pages/flexes_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_shell/app_shell_controller.dart';
import '../flexes/flexes_controller.dart';
import '../flexes/pick_flex_page.dart';
import '../../models/flex_choice.dart';
import '../../widgets/shared_header.dart';
import '../../core/utils/app_colors.dart'; // FIX: Corrected import path

class FlexesPage extends StatelessWidget {
  const FlexesPage({super.key});

  final List<String> _flexPeriods = const [
    'Flex 1', 'Flex 2', 'Flex 3', 'Flex 4'
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final FlexesController controller = Get.put(FlexesController());
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Flexes',
          style: GoogleFonts.inter(
            color: Colors.black, 
            fontWeight: FontWeight.w900, 
            fontSize: screenWidth * 0.07,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: GestureDetector(
              onTap: () {
                final AppShellController appShellController = Get.find();
                appShellController.changePage(4);
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.black, size: 28),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            const SizedBox(height: 8),
            _buildDateSubtitle(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Obx(() => Column(
                children: _flexPeriods
                    .map((title) => _FlexRegistrationSection(
                          title: title,
                          pickedChoice: controller.getPickedFlexFor(title),
                        ))
                    .toList(),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        'For Wednesday, August 28',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _FlexRegistrationSection extends StatelessWidget {
  const _FlexRegistrationSection({required this.title, this.pickedChoice});
  final String title;
  final FlexChoice? pickedChoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
          child: Text(title, style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold)),
        ),
        if (pickedChoice != null)
          _PickedFlexCard(choice: pickedChoice!)
        else
          _RegisterButton(
            title: title,
            onTap: () => Get.to(() => PickFlexPage(flexPeriod: title)),
          ),
      ],
    );
  }
}

class _PickedFlexCard extends StatelessWidget {
  const _PickedFlexCard({required this.choice});
  final FlexChoice choice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(choice.teacher, style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold)),
          Text(choice.room, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text('Register for $title', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
          ],
        ),
      ),
    );
  }
}
