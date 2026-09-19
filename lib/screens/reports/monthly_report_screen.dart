import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_manager_controller.dart';
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
    final authCtrl = Get.find<AuthManagerController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('মাসিক চূড়ান্ত রিপোর্ট', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: () => _selectMonth(context, reportCtrl)),
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: () {
            final r = reportCtrl.currentReport.value;
            if (r != null) Get.to(() => PdfPreviewScreen(report: r));
          }),
        ],
      ),
      body: Obx(() {
        final report = reportCtrl.currentReport.value;
        final manager = authCtrl.currentManager.value;

        if (report == null || report.memberReports.isEmpty) {
          return EmptyStateWidget(icon: Icons.assignment_outlined, title: 'ডেটা পাওয়া যায়নি', message: 'হিসাব যোগ করার পর এখানে রিপোর্ট তৈরি হবে।');
        }

        // To fix duplicate entries in report, we can filter the list here just in case
        final uniqueMemberReports = <String, dynamic>{};
        for (var item in report.memberReports) {
          uniqueMemberReports[item.memberId] = item;
        }
        final finalMemberReports = uniqueMemberReports.values.toList();

        final bool isOwedByManager = report.remainingBalance < 0;
        final Color labelColor = isDark ? Colors.white : Colors.black87;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Card
              Card(
                color: AppColors.primary,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(report.managerName, style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(manager != null ? 'দায়িত্ব: ${AppFormatters.formatDate(manager.joiningDate)}' : '', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 12)),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                        child: Text(AppFormatters.displayMonthKey(report.monthKey), style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Status Box (Manager Owed / Hand Cash)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isOwedByManager ? (isDark ? Colors.red.withAlpha(40) : Colors.red.shade50) : (isDark ? Colors.green.withAlpha(40) : Colors.green.shade50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isOwedByManager ? Colors.red.shade400 : Colors.green.shade400, width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isOwedByManager ? 'ম্যানেজার পাবেন (নিজ খরচ):' : 'ম্যানেজারের কাছে নগদ আছে:',
                          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14, color: isOwedByManager ? (isDark ? Colors.red.shade200 : Colors.red.shade900) : (isDark ? Colors.green.shade200 : Colors.green.shade900)),
                        ),
                        Text(
                          AppFormatters.formatCurrency(report.remainingBalance.abs()),
                          style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: isOwedByManager ? (isDark ? Colors.red.shade300 : Colors.red.shade800) : (isDark ? Colors.green.shade300 : Colors.green.shade800)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Member Table (Separated Owed/Credit Columns)
              Text('সদস্যভিত্তিক চূড়ান্ত হিসাব বিবরণী', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 17, color: labelColor)),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 15,
                    headingRowColor: WidgetStateProperty.all(isDark ? Colors.white10 : Colors.grey.shade100),
                    columns: [
                      DataColumn(label: Text('সদস্য', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('মিল', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('জমা', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('মিল খরচ', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('এক্সট্রা', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('ফেরত পাবে', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.green.shade700))),
                      DataColumn(label: Text('বকেয়া (দিবে)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.red.shade700))),
                    ],
                    rows: finalMemberReports.map((m) {
                      final bool isDue = m.balance < -0.5;
                      final double pabeAmount = !isDue ? m.balance : 0.0;
                      final double dibeAmount = isDue ? m.balance.abs() : 0.0;

                      return DataRow(cells: [
                        DataCell(Text(m.memberName, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13))),
                        DataCell(Text(AppFormatters.formatMeal(m.totalMeal))),
                        DataCell(Text(m.deposit.toStringAsFixed(0))),
                        DataCell(Text(m.mealCost.toStringAsFixed(0))),
                        DataCell(Text(m.extraBill.toStringAsFixed(0))),
                        DataCell(Text(
                          pabeAmount > 0 ? AppFormatters.formatCurrency(pabeAmount) : '-',
                          style: GoogleFonts.hindSiliguri(color: Colors.green, fontWeight: FontWeight.bold),
                        )),
                        DataCell(Text(
                          dibeAmount > 0 ? AppFormatters.formatCurrency(dibeAmount) : '-',
                          style: GoogleFonts.hindSiliguri(color: Colors.red, fontWeight: FontWeight.bold),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              CustomButton(text: 'পুরো রিপোর্ট শেয়ার করুন', icon: Icons.share, onPressed: () => reportCtrl.shareReport()),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }
}
