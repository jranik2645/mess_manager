import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'utils/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with fallback tolerance
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint(
      'Firebase successfully initialized with default platform options.',
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Initialize Firestore and reactive local service
  await FirestoreService().initialize();

  runApp(const MessManagerApp());
}

class MessManagerApp extends StatelessWidget {
  const MessManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}
