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

  final RxInt totalMembersCount = 0.obs;
  final RxDouble totalMeals = 0.0.obs;
  final RxDouble totalDeposit = 0.0.obs;
  final RxDouble totalMessCost = 0.0.obs;
  final RxDouble mealRate = 0.0.obs;
  final RxDouble remainingBalance = 0.0.obs;
  
  // Extra insights
  final RxDouble avgExtraBillPerPerson = 0.0.obs;
  final RxDouble spentPercentage = 0.0.obs; // How much of the total deposit is spent
  
  // Manager wallet logic
  final RxDouble managerPersonalSpent = 0.0.obs; // Amount manager spent from pocket
  final RxDouble cashInHand = 0.0.obs; // Amount manager has in hand

  bool _isCalculating = false;

  @override
  void onInit() {
    super.onInit();
    selectedMonthKey.value = AppFormatters.getMonthKey(DateTime.now());
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
    ever(selectedMonthKey, (String newMonth) {
      mealCtrl.changeMonth(newMonth);
      depositCtrl.changeMonth(newMonth);
      costCtrl.changeMonth(newMonth);
      extraBillCtrl.changeMonth(newMonth);
      recalculateMetrics();
    });
    recalculateMetrics();
  }

  void setMonth(String monthKey) {
    selectedMonthKey.value = monthKey;
  }

  void recalculateMetrics() {
    if (_isCalculating) return;
    _isCalculating = true;

    try {
      final meals = Get.find<MealController>().monthMeals;
      final deposits = Get.find<DepositController>().deposits;
      final costs = Get.find<CostController>().costs;
      final extraBills = Get.find<ExtraBillController>().extraBills;
      final members = Get.find<MemberController>().members;

      totalMembersCount.value = members.length;
      totalMeals.value = CalculationService.calculateTotalMeals(meals);
      totalDeposit.value = CalculationService.calculateTotalDeposits(deposits);
      
      final regCost = CalculationService.calculateTotalRegularCosts(costs);
      final extraCost = CalculationService.calculateTotalExtraBills(extraBills);
      totalMessCost.value = regCost + extraCost;

      mealRate.value = CalculationService.calculateMealRate(regCost, totalMeals.value);
      
      // Calculate extra insights
      final totalActiveMembers = members.where((m) => m.isActive).length;
      avgExtraBillPerPerson.value = totalActiveMembers > 0 ? extraCost / totalActiveMembers : 0.0;
      spentPercentage.value = totalDeposit.value > 0 ? (totalMessCost.value / totalDeposit.value) * 100 : 0.0;

      final balance = totalDeposit.value - totalMessCost.value;
      remainingBalance.value = balance;

     
      if (balance < 0) {
        managerPersonalSpent.value = balance.abs();
        cashInHand.value = 0.0;
      } else {
        managerPersonalSpent.value = 0.0;
        cashInHand.value = balance;
      }

      // Sync member computed fields
      for (var member in members) {
        final mMeals = meals.where((m) => m.memberId == member.id).fold(0.0, (s, m) => s + (m.dayMeal + m.nightMeal));
        final mDep = deposits.where((d) => d.memberId == member.id).fold(0.0, (s, d) => s + d.amount);
        final mExtra = CalculationService.calculateMemberExtraBillShare(member.id, extraBills);
        final mCost = (mMeals * mealRate.value) + mExtra;
        
        member.totalMeal = mMeals;
        member.totalDeposit = mDep;
        member.totalCost = mCost;
        member.balance = mDep - mCost;
      }
      Get.find<MemberController>().members.refresh();
    } finally {
      _isCalculating = false;
    }
  }

  String generateSummaryText() {
    final month = AppFormatters.displayMonthKey(selectedMonthKey.value);
    return '''
--- মেস রিপোর্ট ($month) ---
মিল রেট: ${AppFormatters.formatCurrency(mealRate.value)}
জনপ্রতি এক্সট্রা: ${AppFormatters.formatCurrency(avgExtraBillPerPerson.value)}
মোট জমা: ${AppFormatters.formatCurrency(totalDeposit.value)}
মোট খরচ: ${AppFormatters.formatCurrency(totalMessCost.value)} (খরচ হয়েছে ${spentPercentage.value.toStringAsFixed(1)}%)
অবশিষ্ট নগদ: ${AppFormatters.formatCurrency(cashInHand.value)}
---------------------------
''';
  }
}
