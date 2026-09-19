import '../models/member_model.dart';
import '../models/meal_model.dart';
import '../models/deposit_model.dart';
import '../models/cost_model.dart';
import '../models/extra_bill_model.dart';
import '../models/report_model.dart';

class CalculationService {
  static double calculateTotalDayMeals(List<MealModel> meals) => meals.fold(0.0, (sum, m) => sum + m.dayMeal);
  static double calculateTotalNightMeals(List<MealModel> meals) => meals.fold(0.0, (sum, m) => sum + m.nightMeal);
  static double calculateTotalMeals(List<MealModel> meals) => meals.fold(0.0, (sum, m) => sum + (m.dayMeal + m.nightMeal));
  static double calculateTotalDeposits(List<DepositModel> deposits) => deposits.fold(0.0, (sum, d) => sum + d.amount);
  static double calculateTotalRegularCosts(List<CostModel> costs) => costs.fold(0.0, (sum, c) => sum + c.amount);
  static double calculateTotalExtraBills(List<ExtraBillModel> extraBills) => extraBills.fold(0.0, (sum, b) => sum + b.amount);

  static double calculateMealRate(double regularCost, double totalMeals) {
    if (totalMeals <= 0) return 0.0;
    return regularCost / totalMeals;
  }

  static double calculateMemberExtraBillShare(String memberId, List<ExtraBillModel> extraBills) {
    double totalShare = 0.0;
    for (final bill in extraBills) {
      totalShare += (bill.memberShares[memberId] ?? 0.0);
    }
    return totalShare;
  }

  static Map<String, double> distributeExtraBill({
    required double totalAmount,
    required String distributionType,
    required List<MemberModel> activeMembers,
    List<String>? selectedMemberIds,
    Map<String, double>? manualAmounts,
  }) {
    final Map<String, double> shares = {};
    if (totalAmount <= 0) return shares;

    if (distributionType == 'equal') {
      if (activeMembers.isEmpty) return shares;
      final perMember = double.parse((totalAmount / activeMembers.length).toStringAsFixed(2));
      for (final m in activeMembers) shares[m.id] = perMember;
    } else if (distributionType == 'selected') {
      final validIds = (selectedMemberIds ?? []).where((id) => id.isNotEmpty).toList();
      if (validIds.isEmpty) return shares;
      final perMember = double.parse((totalAmount / validIds.length).toStringAsFixed(2));
      for (final id in validIds) shares[id] = perMember;
    } else if (distributionType == 'manual' && manualAmounts != null) {
      shares.addAll(manualAmounts);
    }
    return shares;
  }

  static MonthlyReportModel generateMonthlyReport({
    required String monthKey,
    required String managerName,
    required List<MemberModel> members,
    required List<MealModel> meals,
    required List<DepositModel> deposits,
    required List<CostModel> costs,
    required List<ExtraBillModel> extraBills,
  }) {
    final tDay = calculateTotalDayMeals(meals);
    final tNight = calculateTotalNightMeals(meals);
    final tMeals = tDay + tNight;
    final tDeposit = calculateTotalDeposits(deposits);
    final tRegularCost = calculateTotalRegularCosts(costs);
    final tExtraBill = calculateTotalExtraBills(extraBills);
    final tTotalCost = tRegularCost + tExtraBill;
    final mRate = calculateMealRate(tRegularCost, tMeals);

    double totalDues = 0.0;
    double totalSurplus = 0.0;

    final List<MemberReportItem> memberReports = members.map((member) {
      final mDay = meals.where((m) => m.memberId == member.id).fold(0.0, (s, m) => s + m.dayMeal);
      final mNight = meals.where((m) => m.memberId == member.id).fold(0.0, (s, m) => s + m.nightMeal);
      final mTotalMeal = mDay + mNight;
      final mDep = deposits.where((d) => d.memberId == member.id).fold(0.0, (s, d) => s + d.amount);
      final mMealCost = mTotalMeal * mRate;
      final mExtra = calculateMemberExtraBillShare(member.id, extraBills);
      final mCost = mMealCost + mExtra;
      final balance = mDep - mCost;

      if (balance < 0) totalDues += balance.abs();
      else totalSurplus += balance;

      return MemberReportItem(
        memberId: member.id,
        memberName: member.name,
        dayMeal: mDay,
        nightMeal: mNight,
        totalMeal: mTotalMeal,
        deposit: mDep,
        mealCost: mMealCost,
        extraBill: mExtra,
        totalCost: mCost,
        balance: balance,
      );
    }).toList();

    return MonthlyReportModel(
      monthKey: monthKey,
      managerName: managerName,
      totalMembers: members.length,
      totalDayMeals: tDay,
      totalNightMeals: tNight,
      totalMeals: tMeals,
      totalDeposit: tDeposit,
      totalRegularCost: tRegularCost,
      totalExtraBill: tExtraBill,
      totalCost: tTotalCost,
      mealRate: mRate,
      remainingBalance: tDeposit - tTotalCost,
      totalDuesFromMembers: totalDues,
      totalSurplusOfMembers: totalSurplus,
      memberReports: memberReports,
    );
  }
}
