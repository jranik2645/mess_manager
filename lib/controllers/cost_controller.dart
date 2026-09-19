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
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    activeMonthKey.value = AppFormatters.getMonthKey(DateTime.now());
    ever(costs, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());
    _bindCostsForMonth(activeMonthKey.value);
  }

  void changeMonth(String monthKey) {
    if (activeMonthKey.value == monthKey) return;
    activeMonthKey.value = monthKey;
    _bindCostsForMonth(monthKey);
  }

  void _bindCostsForMonth(String monthKey) {
    costs.bindStream(_firestoreService.getCostsStream(monthKey));
  }

  void applyFilters() {
    List<CostModel> list = List.from(costs);
    list.sort((a, b) => b.date.compareTo(a.date));

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      list = list.where((c) => c.title.toLowerCase().contains(query)).toList();
    }
    filteredCosts.assignAll(list);
  }

  double get totalCostsInMonth => costs.fold(0.0, (sum, c) => sum + c.amount);

  Future<bool> addCost({required String title, required double amount, required DateTime date, required String category, String addedBy = '', String note = ''}) async {
    try {
      isLoading.value = true;
      final newCost = CostModel(
        id: 'cost_${_uuid.v4().substring(0, 8)}',
        title: title,
        amount: amount,
        date: date,
        monthKey: AppFormatters.getMonthKey(date),
        category: category,
        addedBy: addedBy,
        note: note,
      );
      await _firestoreService.addCost(newCost);
      Get.snackbar('সফল', 'বাজার খরচ সফলভাবে যোগ করা হয়েছে');
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'খরচ যোগ করা যায়নি');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCost(CostModel cost) async {
    try {
      isLoading.value = true;
      await _firestoreService.updateCost(cost);
      Get.snackbar('সফল', 'বাজার খরচ আপডেট করা হয়েছে');
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'আপডেট করা যায়নি');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCost(String id) async {
    try {
      isLoading.value = true;
      await _firestoreService.deleteCost(id, activeMonthKey.value);
      Get.snackbar('সফল', 'খরচ মুছে ফেলা হয়েছে');
    } catch (e) {
      Get.snackbar('ত্রুটি', 'মুছে ফেলা যায়নি');
    } finally {
      isLoading.value = false;
    }
  }
}
