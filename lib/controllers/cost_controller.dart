import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/cost_model.dart';
import '../services/firestore_service.dart';
import '../utils/formatters.dart';

class CostController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  final RxList<CostModel> costs = <CostModel>[].obs;
  final RxList<CostModel> filteredCosts = <CostModel>[].obs;
  final RxString activeMonthKey = ''.obs;

  // Filters
  final RxString selectedCategoryFilter = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    activeMonthKey.value = AppFormatters.getMonthKey(DateTime.now());
    _bindCostsForMonth(activeMonthKey.value);
  }

  void changeMonth(String monthKey) {
    activeMonthKey.value = monthKey;
    _bindCostsForMonth(monthKey);
  }

  void _bindCostsForMonth(String monthKey) {
    costs.bindStream(_firestoreService.getCostsStream(monthKey));
    ever(costs, (_) => applyFilters());
    ever(selectedCategoryFilter, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());
  }

  void applyFilters() {
    List<CostModel> list = List.from(costs);

    if (selectedCategoryFilter.value.isNotEmpty) {
      list = list.where((c) => c.category == selectedCategoryFilter.value).toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      list = list.where((c) {
        final matchTitle = c.title.toLowerCase().contains(query);
        final matchCategory = c.category.toLowerCase().contains(query);
        final matchNote = c.note.toLowerCase().contains(query);
        final matchAddedBy = c.addedBy.toLowerCase().contains(query);
        return matchTitle || matchCategory || matchNote || matchAddedBy;
      }).toList();
    }

    filteredCosts.assignAll(list);
  }

  double get totalCostsInMonth {
    return costs.fold(0.0, (sum, c) => sum + c.amount);
  }

  Map<String, double> get categoryBreakdown {
    final Map<String, double> map = {};
    for (final cost in costs) {
      map[cost.category] = (map[cost.category] ?? 0.0) + cost.amount;
    }
    return map;
  }

  Future<bool> addCost({
    required String title,
    required double amount,
    required DateTime date,
    required String category,
    String addedBy = '',
    String note = '',
  }) async {
    try {
      isLoading.value = true;
      final newCost = CostModel(
        id: 'cost_${_uuid.v4().substring(0, 8)}',
        title: title.trim(),
        amount: amount,
        date: date,
        monthKey: AppFormatters.getMonthKey(date),
        category: category,
        addedBy: addedBy.trim(),
        note: note.trim(),
      );

      await _firestoreService.addCost(newCost);
      Get.snackbar(
        'বাজার খরচ যুক্ত হয়েছে',
        '৳${newCost.amount.toStringAsFixed(0)} (${newCost.title}) সফলভাবে সেভ হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'খরচ সেভ করা যায়নি: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCost(CostModel cost) async {
    try {
      isLoading.value = true;
      await _firestoreService.updateCost(cost);
      Get.snackbar('আপডেট সম্পন্ন', 'বাজার খরচের হিসাব আপডেট হয়েছে', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'আপডেট ব্যর্থ: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteCost(String costId) async {
    try {
      isLoading.value = true;
      await _firestoreService.deleteCost(costId, activeMonthKey.value);
      Get.snackbar('মুছে ফেলা হয়েছে', 'খরচের এন্ট্রি ডিলিট করা হয়েছে', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'ডিলিট ব্যর্থ: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

