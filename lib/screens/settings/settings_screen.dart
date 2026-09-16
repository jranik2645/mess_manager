import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_manager_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/formatters.dart';
import '../../app/routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthManagerController>();
    final themeCtrl = Get.find<ThemeController>();
    final dashCtrl = Get.find<DashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('সেটিংস ও প্রোফাইল'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manager Card
            Obx(() {
              final manager = authCtrl.currentManager.value;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryLight,
                        child: const Icon(Icons.person, size: 34, color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              manager?.name ?? 'মেস ম্যানেজার',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              manager?.phone ?? 'মোবাইল যুক্ত নেই',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            if (manager?.joiningDate != null)
                              Text(
                                'দায়িত্ব গ্রহণ: ${AppFormatters.formatDate(manager!.joiningDate)}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => Get.toNamed(AppRoutes.managerAuth, arguments: true),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('এডিট'),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // App Preferences
            const Text('অ্যাপ সেটিংস', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  Obx(
                    () => SwitchListTile(
                      title: const Text('ডার্ক মোড (Dark Mode)'),
                      subtitle: Text(themeCtrl.isDarkMode.value ? 'ডার্ক থিম সক্রিয়' : 'লাইট থিম সক্রিয়'),
                      secondary: Icon(
                        themeCtrl.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
                        color: AppColors.primary,
                      ),
                      value: themeCtrl.isDarkMode.value,
                      onChanged: (_) => themeCtrl.toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.currency_exchange, color: Colors.green),
                    title: const Text('মুদ্রা প্রতীক (Currency)'),
                    trailing: const Text(
                      '৳ (BDT)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.calendar_month, color: Colors.blue),
                    title: const Text('চলতি হিসাবের মাস'),
                    trailing: Obx(
                      () => Text(
                        AppFormatters.displayMonthKey(dashCtrl.selectedMonthKey.value),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Firebase / Cloud Status
            const Text('ডাটাবেজ স্ট্যাটাস', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_done_rounded, color: Colors.teal),
                title: const Text('Cloud Firestore'),
                subtitle: const Text('রিয়েল-টাইম ক্লাউড সিঙ্ক এবং অফলাইন সাপোর্ট'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.teal.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'সক্রিয়',
                    style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Logout & Exit
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('ম্যানেজার লগআউট', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                onTap: () {
                  authCtrl.logout();
                  Get.offAllNamed(AppRoutes.managerAuth);
                },
              ),
            ),
            const SizedBox(height: 30),

            // App Version Info
            Center(
              child: Column(
                children: [
                  Text(
                    '${AppConstants.appName} v1.0.0',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'স্মার্ট ব্যাচেলর ও মেস ম্যানেজমেন্ট সিস্টেম',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

