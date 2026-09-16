import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/report_model.dart';
import '../services/calculation_service.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart';
import '../utils/formatters.dart';
import 'auth_manager_controller.dart';
import 'member_controller.dart';
import 'meal_controller.dart';
import 'deposit_controller.dart';
import 'cost_controller.dart';
import 'extra_bill_controller.dart';

class ReportController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxString selectedMonthKey = ''.obs;
  final Rx<MonthlyReportModel?> currentReport = Rx<MonthlyReportModel?>(null);
  final RxBool isGenerating = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedMonthKey.value = AppFormatters.getMonthKey(DateTime.now());
    generateReportForCurrentMonth();
  }

  void changeMonth(String monthKey) {
    selectedMonthKey.value = monthKey;
    generateReportForCurrentMonth();
  }

  void generateReportForCurrentMonth() {
    final memberCtrl = Get.find<MemberController>();
    final mealCtrl = Get.find<MealController>();
    final depositCtrl = Get.find<DepositController>();
    final costCtrl = Get.find<CostController>();
    final extraBillCtrl = Get.find<ExtraBillController>();

    final managerName = Get.isRegistered<AuthManagerController>()
        ? (Get.find<AuthManagerController>().currentManager.value?.name ?? 'মেস ম্যানেজার')
        : 'মেস ম্যানেজার';

    final report = CalculationService.generateMonthlyReport(
      monthKey: selectedMonthKey.value,
      managerName: managerName,
      members: memberCtrl.members,
      meals: mealCtrl.monthMeals,
      deposits: depositCtrl.deposits,
      costs: costCtrl.costs,
      extraBills: extraBillCtrl.extraBills,
    );

    currentReport.value = report;
  }

  Future<void> saveReportToCloud() async {
    if (currentReport.value == null) return;
    try {
      isGenerating.value = true;
      await _firestoreService.saveMonthlyReport(currentReport.value!);
      Get.snackbar(
        'রিপোর্ট সংরক্ষিত',
        '${AppFormatters.displayMonthKey(selectedMonthKey.value)} মাসের হিসাব ক্লাউডে আর্কাইভ করা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('ত্রুটি', 'রিপোর্ট সংরক্ষণ ব্যর্থ: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isGenerating.value = false;
    }
  }

  Future<Uint8List?> generatePdfBytes() async {
    if (currentReport.value == null) return null;
    return await PdfService.generateMonthlyReportPdf(currentReport.value!);
  }

  Future<void> printReport() async {
    if (currentReport.value == null) return;
    await PdfService.printReport(currentReport.value!);
  }

  Future<void> shareReport() async {
    if (currentReport.value == null) return;
    await PdfService.shareReport(currentReport.value!);
  }
}

