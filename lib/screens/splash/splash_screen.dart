import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_manager_controller.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await FirestoreService().initialize();

    // Give stream listeners time to populate currentManager (especially demo/offline mode)
    await Future.delayed(const Duration(milliseconds: 1500));

    final authCtrl = Get.find<AuthManagerController>();

    if (authCtrl.currentManager.value != null || authCtrl.isLoggedIn.value) {
      Get.offAllNamed(AppRoutes.mainNav);
    } else {
      // Take the user straight to the dashboard for the single-manager app flow.
      // The manager setup screen remains available from settings when needed.
      Get.offAllNamed(AppRoutes.mainNav);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(60), width: 2),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.appTagline,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha(210),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
