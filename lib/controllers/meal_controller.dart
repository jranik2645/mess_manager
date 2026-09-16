import 'package:get/get.dart';
import '../models/meal_model.dart';
import '../models/member_model.dart';
import '../services/firestore_service.dart';
import '../utils/formatters.dart';

class MealController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString activeMonthKey = ''.obs;

  final RxList<MealModel> monthMeals = <MealModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    activeMonthKey.value = AppFormatters.getMonthKey(selectedDate.value);
    _bindMealsForMonth(activeMonthKey.value);
  }

  void _bindMealsForMonth(String monthKey) {
    monthMeals.bindStream(_firestoreService.getMealsStream(monthKey));
  }

  void changeDate(DateTime newDate) {
    selectedDate.value = newDate;
    final newMonthKey = AppFormatters.getMonthKey(newDate);
    if (newMonthKey != activeMonthKey.value) {
      activeMonthKey.value = newMonthKey;
      _bindMealsForMonth(newMonthKey);
    }
  }

  void changeMonth(String monthKey) {
    activeMonthKey.value = monthKey;
    final parsed = AppFormatters.parseMonthKey(monthKey);
    selectedDate.value = DateTime(parsed.year, parsed.month, 1);
    _bindMealsForMonth(monthKey);
  }

  String get selectedDateKey => AppFormatters.getDateKey(selectedDate.value);

  /// Get meal record for a member on the currently selected date
  MealModel getMealForMember(String memberId, String memberName) {
    final dateKey = selectedDateKey;
    final id = '${activeMonthKey.value}_${dateKey}_$memberId';

    try {
      return monthMeals.firstWhere(
        (m) => m.date == dateKey && m.memberId == memberId,
        orElse: () => MealModel(
          id: id,
          date: dateKey,
          monthKey: activeMonthKey.value,
          memberId: memberId,
          memberName: memberName,
          dayMeal: 0,
          nightMeal: 0,
        ),
      );
    } catch (_) {
      return MealModel(
        id: id,
        date: dateKey,
        monthKey: activeMonthKey.value,
        memberId: memberId,
        memberName: memberName,
        dayMeal: 0,
        nightMeal: 0,
      );
    }
  }

  /// Modify Day Meal for a member by delta (+0.5, +1, -0.5, -1)
  Future<void> updateDayMeal(MemberModel member, double delta) async {
    final current = getMealForMember(member.id, member.name);
    final newDayMeal = (current.dayMeal + delta).clamp(0.0, 20.0);

    final updated = current.copyWith(
      dayMeal: double.parse(newDayMeal.toStringAsFixed(1)),
      updatedAt: DateTime.now(),
    );

    await _firestoreService.setMeal(updated);
  }

  /// Modify Night Meal for a member by delta (+0.5, +1, -0.5, -1)
  Future<void> updateNightMeal(MemberModel member, double delta) async {
    final current = getMealForMember(member.id, member.name);
    final newNightMeal = (current.nightMeal + delta).clamp(0.0, 20.0);

    final updated = current.copyWith(
      nightMeal: double.parse(newNightMeal.toStringAsFixed(1)),
      updatedAt: DateTime.now(),
    );

    await _firestoreService.setMeal(updated);
  }

  /// Set exact values
  Future<void> setExactMeal({
    required MemberModel member,
    required double dayMeal,
    required double nightMeal,
  }) async {
    final current = getMealForMember(member.id, member.name);
    final updated = current.copyWith(
      dayMeal: dayMeal.clamp(0.0, 20.0),
      nightMeal: nightMeal.clamp(0.0, 20.0),
      updatedAt: DateTime.now(),
    );
    await _firestoreService.setMeal(updated);
  }

  /// Quick Bulk: Turn all active members' meals to 1 Day and 1 Night
  Future<void> setAllActiveMeals({
    required List<MemberModel> activeMembers,
    required double dayMeal,
    required double nightMeal,
  }) async {
    try {
      isLoading.value = true;
      for (final member in activeMembers) {
        await setExactMeal(
          member: member,
          dayMeal: dayMeal,
          nightMeal: nightMeal,
        );
      }
      Get.snackbar(
        'সফল',
        'সকল সদস্যের মিল সেট করা হয়েছে (দিন: $dayMeal, রাত: $nightMeal)',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('ত্রুটি', 'মিল আপডেট ব্যর্থ: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Copy meals from previous day
  Future<void> copyFromYesterday(List<MemberModel> activeMembers) async {
    try {
      isLoading.value = true;
      final yesterday = selectedDate.value.subtract(const Duration(days: 1));
      final yesterdayDateKey = AppFormatters.getDateKey(yesterday);

      int copiedCount = 0;
      for (final member in activeMembers) {
        final yesterdayMeal = monthMeals.firstWhereOrNull(
          (m) => m.date == yesterdayDateKey && m.memberId == member.id,
        );
        if (yesterdayMeal != null) {
          await setExactMeal(
            member: member,
            dayMeal: yesterdayMeal.dayMeal,
            nightMeal: yesterdayMeal.nightMeal,
          );
          copiedCount++;
        }
      }

      Get.snackbar(
        'কপি সম্পন্ন',
        'গতকাল ($yesterdayDateKey) থেকে $copiedCount জনের মিল কপি করা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('ত্রুটি', 'কপি করা যায়নি: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Total meals on current selected date
  double get todayTotalDayMeals {
    final dateKey = selectedDateKey;
    return monthMeals
        .where((m) => m.date == dateKey)
        .fold(0.0, (sum, m) => sum + m.dayMeal);
  }

  double get todayTotalNightMeals {
    final dateKey = selectedDateKey;
    return monthMeals
        .where((m) => m.date == dateKey)
        .fold(0.0, (sum, m) => sum + m.nightMeal);
  }

  double get todayTotalMeals => todayTotalDayMeals + todayTotalNightMeals;
}
