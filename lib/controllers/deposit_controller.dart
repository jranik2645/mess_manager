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

  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    activeMonthKey.value = AppFormatters.getMonthKey(DateTime.now());
    
    // Auto-update filter when data changes
    ever(deposits, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());

    _bindDepositsForMonth(activeMonthKey.value);
  }

  void changeMonth(String monthKey) {
    if (activeMonthKey.value == monthKey) return;
    activeMonthKey.value = monthKey;
    _bindDepositsForMonth(monthKey);
  }

  void _bindDepositsForMonth(String monthKey) {
    deposits.bindStream(_firestoreService.getDepositsStream(monthKey));
  }

  void applyFilters() {
    // Sort locally to avoid Firestore Index requirement
    List<DepositModel> list = List.from(deposits);
    list.sort((a, b) => b.date.compareTo(a.date));

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      list = list.where((d) => 
        d.memberName.toLowerCase().contains(query) || 
        d.paymentMethod.toLowerCase().contains(query)
      ).toList();
    }

    filteredDeposits.assignAll(list);
  }

  double get totalDepositsInMonth => deposits.fold(0.0, (sum, d) => sum + d.amount);

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
      Get.snackbar('সফল', 'জমা সফলভাবে যোগ করা হয়েছে');
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'জমা করা যায়নি');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateDeposit(DepositModel deposit) async {
    try {
      isLoading.value = true;
      await _firestoreService.updateDeposit(deposit);
      Get.snackbar('সফল', 'জমা তথ্য আপডেট করা হয়েছে');
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'আপডেট করা যায়নি');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDeposit(String id) async {
    try {
      isLoading.value = true;
      await _firestoreService.deleteDeposit(id, activeMonthKey.value);
      Get.snackbar('সফল', 'জমা মুছে ফেলা হয়েছে');
    } catch (e) {
      Get.snackbar('ত্রুটি', 'মুছে ফেলা যায়নি');
    } finally {
      isLoading.value = false;
    }
  }
}
