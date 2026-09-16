import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/report_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/month_picker_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_widget.dart';
import 'pdf_preview_screen.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  void _selectMonth(BuildContext context, ReportController reportCtrl) {
    showDialog(
      context: context,
      builder: (ctx) => MonthPickerDialog(
        initialMonthKey: reportCtrl.selectedMonthKey.value,
        onMonthSelected: (monthKey) {
          reportCtrl.changeMonth(monthKey);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportCtrl = Get.find<ReportController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('মাসিক চূড়ান্ত রিপোর্ট (Final Report)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'মাস পরিবর্তন',
            onPressed: () => _selectMonth(context, reportCtrl),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF দেখুন ও ডাউনলোড করুন',
            onPressed: () {
              final r = reportCtrl.currentReport.value;
              if (r != null) {
                Get.to(() => PdfPreviewScreen(report: r));
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final report = reportCtrl.currentReport.value;

        if (report == null || report.memberReports.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.assignment_outlined,
            title: 'রিপোর্টের জন্য ডেটা নেই',
            message: 'মেম্বার ও মিলের হিসাব যোগ করার পর স্বয়ংক্রিয়ভাবে রিপোর্ট তৈরি হবে।',
            actionText: 'রিফ্রেশ করুন',
            onAction: () => reportCtrl.generateReportForCurrentMonth(),
          );
        }

        final isNegativeBalance = report.remainingBalance < 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MESS MANAGER FINAL REPORT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        InkWell(
                          onTap: () => _selectMonth(context, reportCtrl),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  AppFormatters.displayMonthKey(report.monthKey),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ম্যানেজার: ${report.managerName.isNotEmpty ? report.managerName : "মেস ম্যানেজার"}',
                      style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary Card
              const Text(
                'মেস সামগ্রিক সারসংক্ষেপ (Mess Summary)',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _summaryRow('মোট সদস্য (Total Members)', '${report.totalMembers} জন'),
                      _summaryRow('দিনের মিল (Day Meals)', AppFormatters.formatMeal(report.totalDayMeals)),
                      _summaryRow('রাতের মিল (Night Meals)', AppFormatters.formatMeal(report.totalNightMeals)),
                      _summaryRow('সর্বমোট মিল (Total Meals)', AppFormatters.formatMeal(report.totalMeals), isBold: true),
                      const Divider(height: 14),
                      _summaryRow('মোট ডিপোজিট/জমা (Deposit)', AppFormatters.formatCurrency(report.totalDeposit), color: Colors.green),
                      _summaryRow('নিয়মিত বাজার খরচ (Regular Cost)', AppFormatters.formatCurrency(report.totalRegularCost), color: Colors.deepOrange),
                      _summaryRow('অতিরিক্ত বিল (Extra Bill)', AppFormatters.formatCurrency(report.totalExtraBill), color: Colors.indigo),
                      _summaryRow('মোট মেস ব্যয় (Total Cost)', AppFormatters.formatCurrency(report.totalCost), isBold: true, color: Colors.red),
                      const Divider(height: 14),
                      _summaryRow(
                        'চূড়ান্ত মিল রেট (Meal Rate)',
                        '${AppFormatters.formatCurrency(report.mealRate)} / মিল',
                        isBold: true,
                        isHighlight: true,
                      ),
                      _summaryRow(
                        'হাতে অবশিষ্ট ক্যাশ ব্যালেন্স',
                        AppFormatters.formatCurrency(report.remainingBalance),
                        isBold: true,
                        color: isNegativeBalance ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Member-wise Breakdown Table
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'সদস্যভিত্তিক হিসাব বিবরণী',
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'মোট: ${report.memberReports.length} জন',
                    style: TextStyle(fontSize: 12.5, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Responsive Horizontal Scrollable Table
              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      isDark ? const Color(0xFF262626) : const Color(0xFFEBF3FA),
                    ),
                    columnSpacing: 18,
                    columns: const [
                      DataColumn(label: Text('সদস্য (Member)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('দিন (Day)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('রাত (Night)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('মোট মিল', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('জমা (Deposit)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('মিল খরচ', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('এক্সট্রা বিল', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('ব্যালেন্স (Balance)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('স্ট্যাটাস', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: report.memberReports.map((m) {
                      final isDue = m.balance < -0.5;
                      final isPositive = m.balance > 0.5;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              m.memberName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          DataCell(Text(AppFormatters.formatMeal(m.dayMeal))),
                          DataCell(Text(AppFormatters.formatMeal(m.nightMeal))),
                          DataCell(
                            Text(
                              AppFormatters.formatMeal(m.totalMeal),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataCell(
                            Text(
                              m.deposit.toStringAsFixed(0),
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                            ),
                          ),
                          DataCell(Text(m.mealCost.toStringAsFixed(1))),
                          DataCell(Text(m.extraBill.toStringAsFixed(1))),
                          DataCell(
                            Text(
                              m.balance.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDue ? Colors.red : (isPositive ? Colors.green : Colors.grey),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDue
                                    ? Colors.red.withAlpha(20)
                                    : (isPositive ? Colors.green.withAlpha(20) : Colors.grey.withAlpha(20)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isDue ? 'বকেয়া' : (isPositive ? 'ফেরত পাবে' : 'সমান'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDue ? Colors.red : (isPositive ? Colors.green : Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Export & Actions Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'PDF ভিউ ও ডাউনলোড',
                      icon: Icons.picture_as_pdf,
                      onPressed: () {
                        Get.to(() => PdfPreviewScreen(report: report));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'প্রিন্ট রিপোর্ট',
                      icon: Icons.print,
                      isOutlined: true,
                      onPressed: () => reportCtrl.printReport(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'শেয়ার করুন',
                      icon: Icons.share,
                      isOutlined: true,
                      onPressed: () => reportCtrl.shareReport(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => CustomButton(
                        text: 'ক্লাউডে সেভ করুন',
                        icon: Icons.cloud_upload_outlined,
                        isLoading: reportCtrl.isGenerating.value,
                        onPressed: () => reportCtrl.saveReportToCloud(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, bool isHighlight = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: isHighlight ? AppColors.primaryLight.withAlpha(50) : Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 15 : 13.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

