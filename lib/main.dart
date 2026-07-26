import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'routes/app_pages.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const NeonSpinApp());
}

class NeonSpinApp extends StatelessWidget {
  const NeonSpinApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Neon Spin: Truth or Dare',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.neonTheme,

      // Routing Configuration
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      // Default Transition for a "Party" feel
      defaultTransition: Transition.cupertino,
    );
  }
}
