import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_manager_controller.dart';
import '../../controllers/cost_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/member_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/month_picker_dialog.dart';
import '../../widgets/summary_card.dart';
import '../members/member_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openMonthPicker(BuildContext context, DashboardController dashCtrl) {
    showDialog(
      context: context,
      builder: (ctx) => MonthPickerDialog(
        initialMonthKey: dashCtrl.selectedMonthKey.value,
        onMonthSelected: (monthKey) => dashCtrl.setMonth(monthKey),
      ),
    );
  }

  void _showFindAccount(BuildContext context) {
    final phoneCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('আপনার মোবাইল নম্বর দিন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '০১৮XXXXXXXX', prefixIcon: Icon(Icons.phone))),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                final member = Get.find<MemberController>().members.firstWhereOrNull((m) => m.phone.contains(phoneCtrl.text.trim()) && phoneCtrl.text.isNotEmpty);
                if (member != null) { Navigator.pop(ctx); Get.to(() => MemberDetailScreen(member: member)); }
                else { Get.snackbar('দুঃখিত', 'এই নম্বরে কোনো মেম্বার পাওয়া যায়নি'); }
              },
              child: const Text('হিসাব দেখুন'),
            ),
            const SizedBox(height: 20),
          ],
        ),
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

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => InkWell(
          onTap: () => _openMonthPicker(context, dashCtrl),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.calendar_month_rounded, size: 20),
            const SizedBox(width: 8),
            Text(AppFormatters.displayMonthKey(dashCtrl.selectedMonthKey.value)),
            const Icon(Icons.arrow_drop_down),
          ]),
        )),
        actions: [
          Obx(() => IconButton(icon: Icon(themeCtrl.isDarkMode.value ? Icons.light_mode : Icons.dark_mode), onPressed: () => themeCtrl.toggleTheme())),
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: () => Share.share(dashCtrl.generateSummaryText())),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => dashCtrl.recalculateMetrics(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1. Manager Status Card
              Obx(() {
                final manager = authCtrl.currentManager.value;
                final isLoggedIn = authCtrl.isLoggedIn.value;
                final balance = dashCtrl.remainingBalance.value;
                
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(50), blurRadius: 10, offset: const Offset(0, 5))]
                  ),
                  child: Column(
                    children: [
                      Row(children: [
                        const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 30)),
                        const SizedBox(width: 15),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(isLoggedIn ? (manager?.name ?? "ম্যানেজার") : "মেস সদস্য ভিউ", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(isLoggedIn ? (manager?.email ?? "ইমেইল নাই") : "আপনার নিজের হিসাব দেখতে সার্চ করুন", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ])),
                        IconButton(icon: Icon(isLoggedIn ? Icons.settings : Icons.login, color: Colors.white), onPressed: () => Get.toNamed(AppRoutes.managerAuth, arguments: isLoggedIn)),
                      ]),
                      const Divider(color: Colors.white24, height: 30),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        _summaryMiniItem("মেস ফান্ড", AppFormatters.formatCurrency(balance), balance < 0 ? Colors.redAccent : Colors.greenAccent),
                        _summaryMiniItem("মিল রেট", AppFormatters.formatCurrency(dashCtrl.mealRate.value), Colors.orangeAccent),
                        _summaryMiniItem("মেম্বার", "${dashCtrl.totalMembersCount.value} জন", Colors.lightBlueAccent),
                      ]),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 25),

              // 2. Financial Progress
              const Align(alignment: Alignment.centerLeft, child: Text("আর্থিক অবস্থা", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              Obx(() => Row(children: [
                _statBox("মোট জমা", AppFormatters.formatCurrency(dashCtrl.totalDeposit.value), Icons.arrow_downward, Colors.green),
                const SizedBox(width: 12),
                _statBox("মোট খরচ", AppFormatters.formatCurrency(dashCtrl.totalMessCost.value), Icons.arrow_upward, Colors.red),
              ])),
              const SizedBox(height: 20),

              // 3. Main Statistics Grid
              Obx(() => GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  SummaryCard(title: "মোট মিল", value: AppFormatters.formatMeal(dashCtrl.totalMeals.value), icon: Icons.restaurant, iconColor: Colors.orange),
                  SummaryCard(title: "জনপ্রতি এক্সট্রা", value: AppFormatters.formatCurrency(dashCtrl.avgExtraBillPerPerson.value), icon: Icons.receipt_long, iconColor: Colors.indigo),
                  SummaryCard(title: "খরচ হয়েছে", value: "${dashCtrl.spentPercentage.value.toStringAsFixed(1)}%", icon: Icons.pie_chart, iconColor: Colors.teal),
                  SummaryCard(title: "ব্যালেন্স", value: AppFormatters.formatCurrency(dashCtrl.remainingBalance.value), icon: Icons.account_balance_wallet, iconColor: Colors.blue),
                ],
              )),
              const SizedBox(height: 30),

              // 4. Action Buttons
              Obx(() {
                if (authCtrl.isLoggedIn.value) {
                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.grey.withAlpha(10), borderRadius: BorderRadius.circular(15)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _quickBtn(Icons.dinner_dining, "মিল", () => navCtrl.goToTab(1), Colors.orange),
                      _quickBtn(Icons.add_card, "জমা", () => navCtrl.goToTab(3, subIndex: 0), Colors.green),
                      _quickBtn(Icons.shopping_bag, "বাজার", () => navCtrl.goToTab(3, subIndex: 1), Colors.deepOrange),
                      _quickBtn(Icons.receipt, "বিল", () => navCtrl.goToTab(3, subIndex: 2), Colors.indigo),
                    ]),
                  );
                }
                return CustomButton(text: "আমার ব্যক্তিগত হিসাব খুঁজুন", icon: Icons.search, onPressed: () => _showFindAccount(context));
              }),

              const SizedBox(height: 25),
              // Recent Bazaar List
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("সাম্প্রতিক বাজার খরচ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () => navCtrl.goToTab(3, subIndex: 1), child: const Text("সব দেখুন")),
              ]),
              Obx(() {
                final costs = costCtrl.costs.take(3).toList();
                if (costs.isEmpty) return const Text("এখনো কোনো বাজার করা হয়নি", style: TextStyle(color: Colors.grey, fontSize: 13));
                return Column(children: costs.map((c) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true, 
                    leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, radius: 15, child: Icon(Icons.shopping_cart, size: 14, color: Colors.white)),
                    title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)), 
                    subtitle: Text(AppFormatters.formatDate(c.date)), 
                    trailing: Text(AppFormatters.formatCurrency(c.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))
                  ),
                )).toList());
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryMiniItem(String label, String value, Color color) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withAlpha(30))),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: color.withAlpha(150), fontSize: 11)),
          Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
      ]),
    ));
  }

  Widget _quickBtn(IconData icon, String label, VoidCallback onTap, Color color) {
    return InkWell(onTap: onTap, child: Column(children: [
      CircleAvatar(radius: 22, backgroundColor: color.withAlpha(20), child: Icon(icon, color: color, size: 20)),
      const SizedBox(height: 5),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
    ]));
  }
}
