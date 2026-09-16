import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/meal_controller.dart';
import '../../controllers/deposit_controller.dart';
import '../../controllers/extra_bill_controller.dart';
import '../../models/member_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';

class MemberDetailScreen extends StatelessWidget {
  final MemberModel member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final dashCtrl = Get.find<DashboardController>();
    final mealCtrl = Get.find<MealController>();
    final depositCtrl = Get.find<DepositController>();
    final extraCtrl = Get.find<ExtraBillController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final monthKey = dashCtrl.selectedMonthKey.value;
    final rate = dashCtrl.mealRate.value;

    // Filter data for this member
    final memberMeals = mealCtrl.monthMeals.where((m) => m.memberId == member.id).toList();
    final memberDeposits = depositCtrl.deposits.where((d) => d.memberId == member.id).toList();
    final memberExtras = extraCtrl.extraBills.where((b) => b.memberShares.containsKey(member.id)).toList();

    final dayMeal = memberMeals.fold(0.0, (s, m) => s + m.dayMeal);
    final nightMeal = memberMeals.fold(0.0, (s, m) => s + m.nightMeal);
    final totalMeal = dayMeal + nightMeal;

    final totalDeposit = memberDeposits.fold(0.0, (s, d) => s + d.amount);
    final mealCost = totalMeal * rate;
    final totalExtra = memberExtras.fold(0.0, (s, b) => s + (b.memberShares[member.id] ?? 0.0));
    final totalCost = mealCost + totalExtra;
    final balance = totalDeposit - totalCost;

    final isDue = balance < -0.5;
    final isPositive = balance > 0.5;

    return Scaffold(
      appBar: AppBar(
        title: Text('${member.name}-এর হিসাব বিবরণী'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      member.name.isNotEmpty ? member.name[0] : 'M',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'মোবাইল: ${member.phone}',
                          style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13),
                        ),
                        if (member.roomNumber.isNotEmpty)
                          Text(
                            'রুম নং: ${member.roomNumber}',
                            style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: member.isActive ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      member.isActive ? 'সক্রিয়' : 'নিষ্ক্রিয়',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Current Month Balance Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDue
                    ? (isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFFEBEE))
                    : (isPositive
                        ? (isDark ? const Color(0xFF1E3824) : const Color(0xFFE8F5E9))
                        : (isDark ? const Color(0xFF262626) : const Color(0xFFF5F5F5))),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDue
                      ? Colors.red.shade400
                      : (isPositive ? Colors.green.shade400 : Colors.grey.shade400),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'মাস: ${AppFormatters.displayMonthKey(monthKey)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isDue ? 'বকেয়া (ম্যানেজারকে দিতে হবে)' : (isPositive ? 'উদ্বৃত্ত জমা (মেম্বার ফেরত পাবে)' : 'ব্যালেন্স সমান'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDue ? Colors.red.shade700 : (isPositive ? Colors.green.shade700 : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.formatCurrency(balance.abs()),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDue ? Colors.red.shade700 : (isPositive ? Colors.green.shade800 : Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Calculation Breakdown Table
            const Text(
              'হিসাবের বিস্তারিত (Calculation Breakdown)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _breakdownRow('দিনের মিল (দুপুর)', AppFormatters.formatMeal(dayMeal)),
                    _breakdownRow('রাতের মিল', AppFormatters.formatMeal(nightMeal)),
                    _breakdownRow('সর্বমোট মিল', AppFormatters.formatMeal(totalMeal), isBold: true),
                    const Divider(height: 16),
                    _breakdownRow('চলতি মিল রেট', '${AppFormatters.formatCurrency(rate)} / মিল'),
                    _breakdownRow('খাবার বাবদ মোট খরচ (মিলের খরচ)', AppFormatters.formatCurrency(mealCost)),
                    _breakdownRow('অতিরিক্ত বিল বাবদ অংশ (Extra Bill)', AppFormatters.formatCurrency(totalExtra)),
                    const Divider(height: 16),
                    _breakdownRow('সদস্যের সর্বমোট ব্যয়', AppFormatters.formatCurrency(totalCost), isBold: true),
                    _breakdownRow('মেম্বারের মোট জমা (Deposit)', AppFormatters.formatCurrency(totalDeposit), isBold: true, color: Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Member Deposits History
            Text(
              'জমা প্রদানের ইতিহাস (${memberDeposits.length} টি)',
              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (memberDeposits.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'চলতি মাসে এখনও কোনো জমা দেওয়া হয়নি',
                      style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                  ),
                ),
              )
            else
              ...memberDeposits.map((dep) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.arrow_downward, color: Colors.green, size: 18),
                    ),
                    title: Text(
                      AppFormatters.formatCurrency(dep.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                    ),
                    subtitle: Text('${dep.paymentMethod} • ${AppFormatters.formatDate(dep.date)}'),
                    trailing: Text(dep.note.isNotEmpty ? dep.note : 'ডিপোজিট'),
                  ),
                );
              }),
            const SizedBox(height: 16),

            // Extra Bills Share
            Text(
              'অতিরিক্ত বিলে অংশগ্রহণ (${memberExtras.length} টি)',
              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (memberExtras.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'চলতি মাসে অতিরিক্ত বিল নেই',
                      style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                  ),
                ),
              )
            else
              ...memberExtras.map((b) {
                final share = b.memberShares[member.id] ?? 0.0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEDE7F6),
                      child: Icon(Icons.receipt_outlined, color: Colors.indigo, size: 18),
                    ),
                    title: Text(
                      b.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text('${b.category} • ${AppFormatters.formatDate(b.date)}'),
                    trailing: Text(
                      'অংশ: ${AppFormatters.formatCurrency(share)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

