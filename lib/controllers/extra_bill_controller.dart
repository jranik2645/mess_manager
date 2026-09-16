import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/extra_bill_model.dart';
import '../models/member_model.dart';
import '../services/calculation_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_constants.dart';
import '../utils/formatters.dart';

class ExtraBillController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  final RxList<ExtraBillModel> extraBills = <ExtraBillModel>[].obs;
  final RxList<ExtraBillModel> filteredBills = <ExtraBillModel>[].obs;
  final RxString activeMonthKey = ''.obs;

  // Filters
  final RxString selectedCategoryFilter = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    activeMonthKey.value = AppFormatters.getMonthKey(DateTime.now());
    _bindBillsForMonth(activeMonthKey.value);
  }

  void changeMonth(String monthKey) {
    activeMonthKey.value = monthKey;
    _bindBillsForMonth(monthKey);
  }

  void _bindBillsForMonth(String monthKey) {
    extraBills.bindStream(_firestoreService.getExtraBillsStream(monthKey));
    ever(extraBills, (_) => applyFilters());
    ever(selectedCategoryFilter, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());
  }

  void applyFilters() {
    List<ExtraBillModel> list = List.from(extraBills);

    if (selectedCategoryFilter.value.isNotEmpty) {
      list = list.where((b) => b.category == selectedCategoryFilter.value).toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      list = list.where((b) {
        final matchTitle = b.title.toLowerCase().contains(query);
        final matchCat = b.category.toLowerCase().contains(query);
        final matchDesc = b.description.toLowerCase().contains(query);
        return matchTitle || matchCat || matchDesc;
      }).toList();
    }

    filteredBills.assignAll(list);
  }

  double get totalExtraBillsInMonth {
    return extraBills.fold(0.0, (sum, b) => sum + b.amount);
  }

  double getMemberTotalExtraShare(String memberId) {
    return CalculationService.calculateMemberExtraBillShare(memberId, extraBills);
  }

  Future<bool> createExtraBill({
    required String title,
    required String category,
    required double amount,
    required DateTime date,
    required String distributionType, // 'equal', 'selected', 'manual'
    required List<MemberModel> activeMembers,
    List<String>? selectedMemberIds,
    Map<String, double>? manualAmounts,
    String description = '',
    String addedBy = '',
  }) async {
    try {
      isLoading.value = true;
      final shares = CalculationService.distributeExtraBill(
        totalAmount: amount,
        distributionType: distributionType,
        activeMembers: activeMembers,
        selectedMemberIds: selectedMemberIds,
        manualAmounts: manualAmounts,
      );

      final newBill = ExtraBillModel(
        id: 'bill_${_uuid.v4().substring(0, 8)}',
        title: title.trim(),
        category: category,
        amount: amount,
        date: date,
        monthKey: AppFormatters.getMonthKey(date),
        distributionType: distributionType,
        memberShares: shares,
        description: description.trim(),
        addedBy: addedBy.trim(),
      );

      await _firestoreService.addExtraBill(newBill);
      Get.snackbar(
        'বিল যুক্ত হয়েছে',
        'অতিরিক্ত বিল "${newBill.title}" (${AppConstants.currencySymbol}${newBill.amount}) বণ্টন করা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'বিল তৈরি করা যায়নি: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateExtraBill(ExtraBillModel bill) async {
    try {
      isLoading.value = true;
      await _firestoreService.updateExtraBill(bill);
      Get.snackbar('আপডেট সম্পন্ন', 'বিল তথ্য আপডেট করা হয়েছে', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'আপডেট করা যায়নি: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteExtraBill(String billId) async {
    try {
      isLoading.value = true;
      await _firestoreService.deleteExtraBill(billId, activeMonthKey.value);
      Get.snackbar('মুছে ফেলা হয়েছে', 'অতিরিক্ত বিল মুছে ফেলা হয়েছে', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'ডিলিট ব্যর্থ: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

