import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_manager_controller.dart';
import '../../controllers/cost_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/month_picker_dialog.dart';
import '../../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openMonthPicker(BuildContext context, DashboardController dashCtrl) {
    showDialog(
      context: context,
      builder: (ctx) => MonthPickerDialog(
        initialMonthKey: dashCtrl.selectedMonthKey.value,
        onMonthSelected: (monthKey) {
          dashCtrl.setMonth(monthKey);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashCtrl = Get.find<DashboardController>();
    final authCtrl = Get.find<AuthManagerController>();
    final themeCtrl = Get.find<ThemeController>();
    final navCtrl = Get.find<NavigationController>();
    final costCtrl = Get.find<CostController>();
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => InkWell(
          onTap: () => _openMonthPicker(context, dashCtrl),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month, size: 20),
              const SizedBox(width: 8),
              Text(AppFormatters.displayMonthKey(dashCtrl.selectedMonthKey.value)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        )),
        actions: [
          Obx(() => IconButton(
            icon: Icon(themeCtrl.isDarkMode.value ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeCtrl.toggleTheme(),
          )),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(dashCtrl.generateSummaryText()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => dashCtrl.recalculateMetrics(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1. Manager Banner
              Obx(() {
                final manager = authCtrl.currentManager.value;
                final isLoggedIn = authCtrl.isLoggedIn.value;
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(Icons.person, color: AppColors.primary)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(isLoggedIn ? (manager?.name ?? "ম্যানেজার") : "পাবলিক ভিউ", 
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(isLoggedIn ? (manager?.email ?? "ইমেইল সেট করা নেই") : "লগইন করে হিসাব আপডেট করুন", 
                                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(isLoggedIn ? Icons.settings : Icons.login, color: Colors.white),
                          onPressed: () => Get.toNamed(AppRoutes.managerAuth, arguments: isLoggedIn),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // 2. Highlights (Rate & Balance)
              Obx(() {
                final balance = dashCtrl.remainingBalance.value;
                return Row(
                  children: [
                    _highlightBox("মিল রেট", AppFormatters.formatCurrency(dashCtrl.mealRate.value), Icons.trending_up, Colors.green),
                    const SizedBox(width: 12),
                    _highlightBox("ক্যাশ ব্যালেন্স", AppFormatters.formatCurrency(balance), Icons.account_balance_wallet, balance < 0 ? Colors.red : Colors.blue),
                  ],
                );
              }),
              const SizedBox(height: 20),

              // 3. Grid Overview
              const Align(alignment: Alignment.centerLeft, child: Text("মাসিক সারসংক্ষেপ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              Obx(() => GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: [
                  SummaryCard(title: "মোট সদস্য", value: "${dashCtrl.totalMembersCount.value} জন", icon: Icons.people, iconColor: Colors.purple),
                  SummaryCard(title: "মোট মিল", value: AppFormatters.formatMeal(dashCtrl.totalMeals.value), icon: Icons.restaurant, iconColor: Colors.orange),
                  SummaryCard(title: "মোট জমা", value: AppFormatters.formatCurrency(dashCtrl.totalDeposit.value), icon: Icons.savings, iconColor: Colors.green),
                  SummaryCard(title: "মোট খরচ", value: AppFormatters.formatCurrency(dashCtrl.totalMessCost.value), icon: Icons.payments, iconColor: Colors.red),
                ],
              )),
              const SizedBox(height: 25),

              // 4. Quick Actions
              Obx(() {
                if (!authCtrl.isLoggedIn.value) return const SizedBox.shrink();
                return Column(
                  children: [
                    const Align(alignment: Alignment.centerLeft, child: Text("দ্রুত কার্যক্রম", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _actionIcon(Icons.add_task, "মিল দিন", () => navCtrl.goToTab(1)),
                        _actionIcon(Icons.add_card, "জমা নিন", () => navCtrl.goToTab(3, subIndex: 0)),
                        _actionIcon(Icons.shopping_cart, "বাজার", () => navCtrl.goToTab(3, subIndex: 1)),
                        _actionIcon(Icons.receipt, "বিল", () => navCtrl.goToTab(3, subIndex: 2)),
                      ],
                    ),
                  ],
                );
              }),
              
              const SizedBox(height: 20),
              // Recent List
              const Align(alignment: Alignment.centerLeft, child: Text("সাম্প্রতিক বাজার খরচ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              Obx(() {
                final costs = costCtrl.costs.take(3).toList();
                if (costs.isEmpty) return const Text("কোনো খরচ নেই");
                return Column(
                  children: costs.map((c) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.shopping_bag_outlined, color: Colors.deepOrange),
                    title: Text(c.title),
                    subtitle: Text(AppFormatters.formatDate(c.date)),
                    trailing: Text(AppFormatters.formatCurrency(c.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                  )).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _highlightBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withAlpha(50))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
