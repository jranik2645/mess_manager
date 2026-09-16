import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/deposit_model.dart';
import '../services/firestore_service.dart';
import '../utils/formatters.dart';

class DepositController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  final RxList<DepositModel> deposits = <DepositModel>[].obs;
  final RxList<DepositModel> filteredDeposits = <DepositModel>[].obs;
  final RxString activeMonthKey = ''.obs;

  // Filters
  final RxString selectedMemberIdFilter = ''.obs;
  final RxString selectedPaymentMethodFilter = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    activeMonthKey.value = AppFormatters.getMonthKey(DateTime.now());
    _bindDepositsForMonth(activeMonthKey.value);
  }

  void changeMonth(String monthKey) {
    activeMonthKey.value = monthKey;
    _bindDepositsForMonth(monthKey);
  }

  void _bindDepositsForMonth(String monthKey) {
    deposits.bindStream(_firestoreService.getDepositsStream(monthKey));
    ever(deposits, (_) => applyFilters());
    ever(selectedMemberIdFilter, (_) => applyFilters());
    ever(selectedPaymentMethodFilter, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());
  }

  void applyFilters() {
    List<DepositModel> list = List.from(deposits);

    if (selectedMemberIdFilter.value.isNotEmpty) {
      list = list.where((d) => d.memberId == selectedMemberIdFilter.value).toList();
    }

    if (selectedPaymentMethodFilter.value.isNotEmpty) {
      list = list.where((d) => d.paymentMethod == selectedPaymentMethodFilter.value).toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      list = list.where((d) {
        final matchMember = d.memberName.toLowerCase().contains(query);
        final matchNote = d.note.toLowerCase().contains(query);
        final matchMethod = d.paymentMethod.toLowerCase().contains(query);
        return matchMember || matchNote || matchMethod;
      }).toList();
    }

    filteredDeposits.assignAll(list);
  }

  double get totalDepositsInMonth {
    return deposits.fold(0.0, (sum, d) => sum + d.amount);
  }

  double getMemberTotalDeposit(String memberId) {
    return deposits
        .where((d) => d.memberId == memberId)
        .fold(0.0, (sum, d) => sum + d.amount);
  }

  Future<bool> addDeposit({
    required String memberId,
    required String memberName,
    required double amount,
    required DateTime date,
    required String paymentMethod,
    String note = '',
  }) async {
    try {
      isLoading.value = true;
      final newDeposit = DepositModel(
        id: 'dep_${_uuid.v4().substring(0, 8)}',
        memberId: memberId,
        memberName: memberName,
        amount: amount,
        date: date,
        monthKey: AppFormatters.getMonthKey(date),
        paymentMethod: paymentMethod,
        note: note.trim(),
      );

      await _firestoreService.addDeposit(newDeposit);
      Get.snackbar(
        'জমা সম্পন্ন',
        '${newDeposit.memberName}-এর ৳${newDeposit.amount.toStringAsFixed(0)} জমা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'জমা যোগ করা যায়নি: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateDeposit(DepositModel deposit) async {
    try {
      isLoading.value = true;
      await _firestoreService.updateDeposit(deposit);
      Get.snackbar(
        'আপডেট সফল',
        'জমার তথ্য আপডেট হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'আপডেট ব্যর্থ: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteDeposit(String depositId) async {
    try {
      isLoading.value = true;
      await _firestoreService.deleteDeposit(depositId, activeMonthKey.value);
      Get.snackbar(
        'মুছে ফেলা হয়েছে',
        'জমার রেকর্ড মুছে ফেলা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'মুছে ফেলা যায়নি: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

