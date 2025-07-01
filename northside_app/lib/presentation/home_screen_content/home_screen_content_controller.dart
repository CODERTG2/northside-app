import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreenContentController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPageIndex = 0.obs;
  final RxInt actualEventCount = 0.obs;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    if (actualEventCount.value > 0) {
      currentPageIndex.value = index % actualEventCount.value;
    }
  }

  void setEventCount(int count) {
    actualEventCount.value = count;
  }

  int getVirtualIndex(int actualIndex) {
    if (actualEventCount.value <= 1) return actualIndex;
    // Start from a high number to allow backward scrolling
    return actualIndex + (10000 * actualEventCount.value);
  }
}
