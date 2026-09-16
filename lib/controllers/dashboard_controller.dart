import 'package:get/get.dart';

import '../models/cost_model.dart';
import '../models/deposit_model.dart';
import '../models/extra_bill_model.dart';
import '../models/meal_model.dart';
import '../models/member_model.dart';
import '../services/calculation_service.dart';
import '../utils/formatters.dart';
import 'auth_manager_controller.dart';
import 'cost_controller.dart';
import 'deposit_controller.dart';
import 'extra_bill_controller.dart';
import 'meal_controller.dart';
import 'member_controller.dart';

class DashboardController extends GetxController {
  final RxString selectedMonthKey = ''.obs;

  // Real-time calculated reactive variables
  final RxInt totalMembersCount = 0.obs;
  final RxInt activeMembersCount = 0.obs;

  final RxDouble totalDayMeals = 0.0.obs;
  final RxDouble totalNightMeals = 0.0.obs;
  final RxDouble totalMeals = 0.0.obs;

  final RxDouble totalDeposit = 0.0.obs;
  final RxDouble totalRegularCost = 0.0.obs;
  final RxDouble totalExtraBill = 0.0.obs;
  final RxDouble totalMessCost = 0.0.obs;

  final RxDouble mealRate = 0.0.obs;
  final RxDouble remainingBalance = 0.0.obs;

  // Guard flag — prevents ever() listener from triggering recursive recalculation
  bool _isCalculating = false;

  @override
  void onInit() {
    super.onInit();
    selectedMonthKey.value = AppFormatters.getMonthKey(DateTime.now());

    // Listen to changes across all controllers to auto recalculate
    _setupAutoCalculation();
  }

  void _setupAutoCalculation() {
    final memberCtrl = Get.find<MemberController>();
    final mealCtrl = Get.find<MealController>();
    final depositCtrl = Get.find<DepositController>();
    final costCtrl = Get.find<CostController>();
    final extraBillCtrl = Get.find<ExtraBillController>();

    ever(memberCtrl.members, (_) => recalculateMetrics());
    ever(mealCtrl.monthMeals, (_) => recalculateMetrics());
    ever(depositCtrl.deposits, (_) => recalculateMetrics());
    ever(costCtrl.costs, (_) => recalculateMetrics());
    ever(extraBillCtrl.extraBills, (_) => recalculateMetrics());
    ever(selectedMonthKey, (newMonth) {
      mealCtrl.changeMonth(newMonth);
      depositCtrl.changeMonth(newMonth);
      costCtrl.changeMonth(newMonth);
      extraBillCtrl.changeMonth(newMonth);
      recalculateMetrics();
    });

    // Initial calculation
    recalculateMetrics();
  }

  void setMonth(String monthKey) {
    selectedMonthKey.value = monthKey;
  }

  void recalculateMetrics() {
    // Prevent infinite loop: ever(members) → recalculate → members.refresh() → ever(members) → ...
    if (_isCalculating) return;
    _isCalculating = true;

    try {
      final memberCtrl = Get.find<MemberController>();
      final mealCtrl = Get.find<MealController>();
      final depositCtrl = Get.find<DepositController>();
      final costCtrl = Get.find<CostController>();
      final extraBillCtrl = Get.find<ExtraBillController>();

      final List<MemberModel> allMembers = memberCtrl.members;
      final List<MealModel> meals = mealCtrl.monthMeals;
      final List<DepositModel> deposits = depositCtrl.deposits;
      final List<CostModel> costs = costCtrl.costs;
      final List<ExtraBillModel> extraBills = extraBillCtrl.extraBills;

      totalMembersCount.value = allMembers.length;
      activeMembersCount.value = allMembers.where((m) => m.isActive).length;

      totalDayMeals.value = CalculationService.calculateTotalDayMeals(meals);
      totalNightMeals.value = CalculationService.calculateTotalNightMeals(
        meals,
      );
      totalMeals.value = totalDayMeals.value + totalNightMeals.value;

      totalDeposit.value = CalculationService.calculateTotalDeposits(deposits);
      totalRegularCost.value = CalculationService.calculateTotalRegularCosts(
        costs,
      );
      totalExtraBill.value = CalculationService.calculateTotalExtraBills(
        extraBills,
      );
      totalMessCost.value = totalRegularCost.value + totalExtraBill.value;

      mealRate.value = CalculationService.calculateMealRate(
        totalRegularCost.value,
        totalMeals.value,
      );
      remainingBalance.value = CalculationService.calculateRemainingBalance(
        totalDeposit: totalDeposit.value,
        totalRegularCost: totalRegularCost.value,
        totalExtraBill: totalExtraBill.value,
      );

      // Update per-member computed fields directly on the model (no refresh() call).
      // Calling members.refresh() here would re-fire the ever() listener → Stack Overflow.
      for (final member in allMembers) {
        final mDay = CalculationService.calculateMemberDayMeals(
          member.id,
          meals,
        );
        final mNight = CalculationService.calculateMemberNightMeals(
          member.id,
          meals,
        );
        final mTotal = mDay + mNight;
        final mDep = CalculationService.calculateMemberDeposit(
          member.id,
          deposits,
        );
        final mMealCost = mTotal * mealRate.value;
        final mExtra = CalculationService.calculateMemberExtraBillShare(
          member.id,
          extraBills,
        );
        final mCost = mMealCost + mExtra;
        final mBal = mDep - mCost;

        member.totalMeal = mTotal;
        member.totalDeposit = mDep;
        member.totalCost = mCost;
        member.balance = mBal;
      }
    } finally {
      _isCalculating = false;
    }
  }

  String get currentManagerName {
    if (Get.isRegistered<AuthManagerController>()) {
      return Get.find<AuthManagerController>().currentManager.value?.name ??
          'মেস ম্যানেজার';
    }
    return 'মেস ম্যানেজার';
  }

  String generateSummaryText() {
    final month = AppFormatters.displayMonthKey(selectedMonthKey.value);
    final rate = AppFormatters.formatCurrency(mealRate.value);
    final deposit = AppFormatters.formatCurrency(totalDeposit.value);
    final cost = AppFormatters.formatCurrency(totalMessCost.value);
    final balance = AppFormatters.formatCurrency(remainingBalance.value);

    return '''
--- মেস ম্যানেজার রিপোর্ট ($month) ---
মোট মিল: ${totalMeals.value}
মিল রেট: $rate
মোট জমা: $deposit
মোট খরচ: $cost
হাতে নগদ: $balance

সদস্য সংখ্যা: ${activeMembersCount.value} জন
---------------------------
''';
  }
}
