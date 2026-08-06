import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'routes/app_pages.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

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
      theme: AppTheme.offWhiteNeonTheme,

      // Routing Configuration
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      // Default Transition for a "Party" feel
      defaultTransition: Transition.cupertino,
    );
  }
}
