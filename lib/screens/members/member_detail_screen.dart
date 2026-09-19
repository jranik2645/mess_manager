import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_manager_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/member_model.dart';
import '../../services/notification_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';

class MemberDetailScreen extends StatelessWidget {
  final MemberModel member;
  const MemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthManagerController>();
    final dashCtrl = Get.find<DashboardController>();
    
    final bool isDue = member.balance < -0.5;
    final String currentMonth = AppFormatters.displayMonthKey(dashCtrl.selectedMonthKey.value);

    return Scaffold(
      appBar: AppBar(
        title: Text('${member.name}-এর হিসাব'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Member Info Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.primary.withAlpha(30),
                      child: Text(member.name[0], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                    const SizedBox(height: 12),
                    Text(member.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('রুম: ${member.roomNumber}', style: TextStyle(color: Colors.grey.shade600)),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem('মোট মিল', AppFormatters.formatMeal(member.totalMeal)),
                        _statItem('মোট জমা', AppFormatters.formatCurrency(member.totalDeposit)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Balance Card
            Card(
              color: isDue ? Colors.red.shade50 : Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('বর্তমান ব্যালেন্স:', style: TextStyle(fontWeight: FontWeight.bold, color: isDue ? Colors.red.shade900 : Colors.green.shade900)),
                    Text(
                      AppFormatters.formatCurrency(member.balance),
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDue ? Colors.red : Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Notification Section (Only for Manager)
            Obx(() {
              if (!authCtrl.isLoggedIn.value) return const SizedBox.shrink();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('বকেয়া বিল নোটিশ পাঠান', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _notificationButton(
                    icon: Icons.message_rounded,
                    label: 'SMS পাঠান',
                    color: Colors.blue,
                    onTap: () => NotificationService.sendDueSMS(
                      phone: member.phone,
                      memberName: member.name,
                      dueAmount: member.balance,
                      month: currentMonth,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _notificationButton(
                    icon: Icons.chat_rounded,
                    label: 'WhatsApp করুন',
                    color: Colors.green,
                    onTap: () => NotificationService.sendDueWhatsApp(
                      phone: member.phone,
                      memberName: member.name,
                      dueAmount: member.balance,
                      month: currentMonth,
                    ),
                  ),
                  if (member.email.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _notificationButton(
                      icon: Icons.email_rounded,
                      label: 'ইমেইল পাঠান',
                      color: Colors.orange.shade800,
                      onTap: () => NotificationService.sendDueEmail(
                        email: member.email,
                        memberName: member.name,
                        dueAmount: member.balance,
                        month: currentMonth,
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _notificationButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }
}
