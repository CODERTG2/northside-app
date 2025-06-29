import 'package:get/get.dart';
import '../../presentation/app_shell/app_shell_binding.dart';
import '../../presentation/app_shell/app_shell_screen.dart';

class AppRoutes {
  // Define a name for our shell route.
  static const String appShell = '/app_shell';

  // The app will start at this route.
  static const String initialRoute = appShell;

  static List<GetPage> pages = [
    GetPage(
      name: appShell,
      page: () => const AppShellScreen(),
      // This is the correct way to provide controllers to this route.
      binding: AppShellBinding(),
    ),
    // TODO: When you build the "More Details" page for Homecoming,
    // you would add its route here like this:
    // GetPage(name: '/homecoming_details', page: () => HomecomingDetailPage()),
  ];
}
