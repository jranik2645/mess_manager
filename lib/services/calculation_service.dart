import '../models/member_model.dart';
import '../models/meal_model.dart';
import '../models/deposit_model.dart';
import '../models/cost_model.dart';
import '../models/extra_bill_model.dart';
import '../models/report_model.dart';

class CalculationService {
  /// Calculate Total Day Meals from a list of meals
  static double calculateTotalDayMeals(List<MealModel> meals) {
    return meals.fold(0.0, (sum, m) => sum + m.dayMeal);
  }

  /// Calculate Total Night Meals from a list of meals
  static double calculateTotalNightMeals(List<MealModel> meals) {
    return meals.fold(0.0, (sum, m) => sum + m.nightMeal);
  }

  /// Calculate Total Meals (Day + Night)
  static double calculateTotalMeals(List<MealModel> meals) {
    return meals.fold(0.0, (sum, m) => sum + m.totalMeal);
  }

  /// Calculate Total Deposits
  static double calculateTotalDeposits(List<DepositModel> deposits) {
    return deposits.fold(0.0, (sum, d) => sum + d.amount);
  }

  /// Calculate Total Regular Costs (Bazaar)
  static double calculateTotalRegularCosts(List<CostModel> costs) {
    return costs.fold(0.0, (sum, c) => sum + c.amount);
  }

  /// Calculate Total Extra Bills
  static double calculateTotalExtraBills(List<ExtraBillModel> extraBills) {
    return extraBills.fold(0.0, (sum, b) => sum + b.amount);
  }

  /// Total Expenditure = Regular Cost + Extra Bills
  static double calculateTotalExpenditure(double regularCost, double extraBill) {
    return regularCost + extraBill;
  }

  /// Calculate Meal Rate = Regular Bazaar Cost / Total Meals
  /// Returns 0.0 if totalMeals <= 0 to avoid division by zero
  static double calculateMealRate(double regularCost, double totalMeals) {
    if (totalMeals <= 0) return 0.0;
    return regularCost / totalMeals;
  }

  /// Calculate Member Day Meals
  static double calculateMemberDayMeals(String memberId, List<MealModel> meals) {
    return meals
        .where((m) => m.memberId == memberId)
        .fold(0.0, (sum, m) => sum + m.dayMeal);
  }

  /// Calculate Member Night Meals
  static double calculateMemberNightMeals(String memberId, List<MealModel> meals) {
    return meals
        .where((m) => m.memberId == memberId)
        .fold(0.0, (sum, m) => sum + m.nightMeal);
  }

  /// Calculate Member Total Meals
  static double calculateMemberTotalMeals(String memberId, List<MealModel> meals) {
    return meals
        .where((m) => m.memberId == memberId)
        .fold(0.0, (sum, m) => sum + m.totalMeal);
  }

  /// Calculate Member Total Deposit
  static double calculateMemberDeposit(String memberId, List<DepositModel> deposits) {
    return deposits
        .where((d) => d.memberId == memberId)
        .fold(0.0, (sum, d) => sum + d.amount);
  }

  /// Calculate Member Extra Bill Share
  static double calculateMemberExtraBillShare(String memberId, List<ExtraBillModel> extraBills) {
    double totalShare = 0.0;
    for (final bill in extraBills) {
      if (bill.memberShares.containsKey(memberId)) {
        totalShare += (bill.memberShares[memberId] ?? 0.0);
      }
    }
    return totalShare;
  }

  /// Calculate Member Balance = Deposit - Meal Cost - Extra Bill
  /// Positive: returnable / credit
  /// Negative: due / payable
  static double calculateMemberBalance({
    required double deposit,
    required double mealCost,
    required double extraBillShare,
  }) {
    return deposit - (mealCost + extraBillShare);
  }

  /// Mess Remaining Cash in Hand = Total Deposit - (Total Regular Cost + Total Extra Bill)
  static double calculateRemainingBalance({
    required double totalDeposit,
    required double totalRegularCost,
    required double totalExtraBill,
  }) {
    return totalDeposit - (totalRegularCost + totalExtraBill);
  }

  /// Distribute an Extra Bill among members
  /// distributionType: 'equal' (all members split equally),
  /// 'selected' (specified subset split equally),
  /// 'manual' (custom map)
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
      final perMember = totalAmount / activeMembers.length;
      for (final m in activeMembers) {
        shares[m.id] = double.parse(perMember.toStringAsFixed(2));
      }
    } else if (distributionType == 'selected') {
      final validSelected = (selectedMemberIds ?? []).where((id) => id.isNotEmpty).toList();
      if (validSelected.isEmpty) return shares;
      final perMember = totalAmount / validSelected.length;
      for (final id in validSelected) {
        shares[id] = double.parse(perMember.toStringAsFixed(2));
      }
    } else if (distributionType == 'manual') {
      if (manualAmounts != null) {
        shares.addAll(manualAmounts);
      }
    }

    return shares;
  }

  /// Generate complete monthly audit and report
  static MonthlyReportModel generateMonthlyReport({
    required String monthKey,
    required String managerName,
    required List<MemberModel> members,
    required List<MealModel> meals,
    required List<DepositModel> deposits,
    required List<CostModel> costs,
    required List<ExtraBillModel> extraBills,
  }) {
    final totalDayMeals = calculateTotalDayMeals(meals);
    final totalNightMeals = calculateTotalNightMeals(meals);
    final totalMeals = totalDayMeals + totalNightMeals;

    final totalDeposit = calculateTotalDeposits(deposits);
    final totalRegularCost = calculateTotalRegularCosts(costs);
    final totalExtraBill = calculateTotalExtraBills(extraBills);
    final totalCost = totalRegularCost + totalExtraBill;

    final mealRate = calculateMealRate(totalRegularCost, totalMeals);
    final remainingBalance = totalDeposit - totalCost;

    final List<MemberReportItem> memberReports = [];

    for (final member in members) {
      final memberDayMeal = calculateMemberDayMeals(member.id, meals);
      final memberNightMeal = calculateMemberNightMeals(member.id, meals);
      final memberTotalMeal = memberDayMeal + memberNightMeal;

      final memberDeposit = calculateMemberDeposit(member.id, deposits);
      final memberMealCost = memberTotalMeal * mealRate;
      final memberExtraBill = calculateMemberExtraBillShare(member.id, extraBills);
      final memberTotalCost = memberMealCost + memberExtraBill;
      final memberBalance = memberDeposit - memberTotalCost;

      // Update runtime cached fields on member
      member.totalMeal = memberTotalMeal;
      member.totalDeposit = memberDeposit;
      member.totalCost = memberTotalCost;
      member.balance = memberBalance;

      memberReports.add(
        MemberReportItem(
          memberId: member.id,
          memberName: member.name,
          dayMeal: memberDayMeal,
          nightMeal: memberNightMeal,
          totalMeal: memberTotalMeal,
          deposit: memberDeposit,
          mealCost: memberMealCost,
          extraBill: memberExtraBill,
          totalCost: memberTotalCost,
          balance: memberBalance,
        ),
      );
    }

    return MonthlyReportModel(
      monthKey: monthKey,
      managerName: managerName,
      totalMembers: members.length,
      totalDayMeals: totalDayMeals,
      totalNightMeals: totalNightMeals,
      totalMeals: totalMeals,
      totalDeposit: totalDeposit,
      totalRegularCost: totalRegularCost,
      totalExtraBill: totalExtraBill,
      totalCost: totalCost,
      mealRate: mealRate,
      remainingBalance: remainingBalance,
      memberReports: memberReports,
    );
  }
}

