import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/extra_bill_model.dart';
import '../models/member_model.dart';
import '../services/calculation_service.dart';
import '../services/firestore_service.dart';
import '../utils/formatters.dart';

class ExtraBillController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  final RxList<ExtraBillModel> extraBills = <ExtraBillModel>[].obs;
  final RxList<ExtraBillModel> filteredBills = <ExtraBillModel>[].obs;
  final RxString activeMonthKey = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    activeMonthKey.value = AppFormatters.getMonthKey(DateTime.now());
    ever(extraBills, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());
    _bindBillsForMonth(activeMonthKey.value);
  }

  void changeMonth(String monthKey) {
    if (activeMonthKey.value == monthKey) return;
    activeMonthKey.value = monthKey;
    _bindBillsForMonth(monthKey);
  }

  void _bindBillsForMonth(String monthKey) {
    extraBills.bindStream(_firestoreService.getExtraBillsStream(monthKey));
  }

  void applyFilters() {
    List<ExtraBillModel> list = List.from(extraBills);
    list.sort((a, b) => b.date.compareTo(a.date));

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      list = list.where((b) => b.title.toLowerCase().contains(query)).toList();
    }
    filteredBills.assignAll(list);
  }

  double get totalExtraBillsInMonth => extraBills.fold(0.0, (sum, b) => sum + b.amount);

  Future<bool> createExtraBill({
    required String title, required String category, required double amount, 
    required DateTime date, required String distributionType, required List<MemberModel> activeMembers,
    List<String>? selectedMemberIds, Map<String, double>? manualAmounts, String description = '', String addedBy = '',
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
        title: title,
        category: category,
        amount: amount,
        date: date,
        monthKey: AppFormatters.getMonthKey(date),
        distributionType: distributionType,
        memberShares: shares,
        description: description,
        addedBy: addedBy,
      );

      await _firestoreService.addExtraBill(newBill);
      Get.snackbar('সফল', 'অতিরিক্ত বিল সফলভাবে বণ্টন করা হয়েছে');
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'বিল তৈরি করা যায়নি');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateExtraBill(ExtraBillModel bill) async {
    try {
      isLoading.value = true;
      await _firestoreService.updateExtraBill(bill);
      Get.snackbar('সফল', 'বিল তথ্য আপডেট করা হয়েছে');
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'আপডেট করা যায়নি');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExtraBill(String id) async {
    try {
      isLoading.value = true;
      await _firestoreService.deleteExtraBill(id, activeMonthKey.value);
      Get.snackbar('সফল', 'বিল মুছে ফেলা হয়েছে');
    } catch (e) {
      Get.snackbar('ত্রুটি', 'মুছে ফেলা যায়নি');
    } finally {
      isLoading.value = false;
    }
  }
}
