// lib/presentation/app_shell/app_shell_binding.dart

import 'package:get/get.dart'; // THIS IS THE MISSING LINE
import 'app_shell_controller.dart';
import '../home_screen_content/home_screen_content_controller.dart';
import '../flexes/flexes_controller.dart';
import '../controllers/bulletin_controller.dart';

class AppShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppShellController());
    Get.lazyPut(() => HomeScreenContentController());
    Get.lazyPut(() => FlexesController());
    Get.put(BulletinController(), permanent: true); // Ensure BulletinController is always available
  }
}
