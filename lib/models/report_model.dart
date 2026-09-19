import 'package:cloud_firestore/cloud_firestore.dart';

class MemberReportItem {
  final String memberId;
  final String memberName;
  final double dayMeal;
  final double nightMeal;
  final double totalMeal;
  final double deposit;
  final double mealCost;
  final double extraBill;
  final double totalCost;
  final double balance; // deposit - totalCost

  MemberReportItem({
    required this.memberId,
    required this.memberName,
    required this.dayMeal,
    required this.nightMeal,
    required this.totalMeal,
    required this.deposit,
    required this.mealCost,
    required this.extraBill,
    required this.totalCost,
    required this.balance,
  });

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'dayMeal': dayMeal,
      'nightMeal': nightMeal,
      'totalMeal': totalMeal,
      'deposit': deposit,
      'mealCost': mealCost,
      'extraBill': extraBill,
      'totalCost': totalCost,
      'balance': balance,
    };
  }

  factory MemberReportItem.fromMap(Map<String, dynamic> map) {
    return MemberReportItem(
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      dayMeal: (map['dayMeal'] as num?)?.toDouble() ?? 0.0,
      nightMeal: (map['nightMeal'] as num?)?.toDouble() ?? 0.0,
      totalMeal: (map['totalMeal'] as num?)?.toDouble() ?? 0.0,
      deposit: (map['deposit'] as num?)?.toDouble() ?? 0.0,
      mealCost: (map['mealCost'] as num?)?.toDouble() ?? 0.0,
      extraBill: (map['extraBill'] as num?)?.toDouble() ?? 0.0,
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0.0,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MonthlyReportModel {
  final String monthKey;
  final String managerName;
  final int totalMembers;
  final double totalDayMeals;
  final double totalNightMeals;
  final double totalMeals;
  final double totalDeposit;
  final double totalRegularCost;
  final double totalExtraBill;
  final double totalCost;
  final double mealRate;
  final double remainingBalance;
  
  // New Summary Fields
  final double totalDuesFromMembers; // Sum of all negative balances
  final double totalSurplusOfMembers; // Sum of all positive balances

  final List<MemberReportItem> memberReports;
  final DateTime generatedAt;

  MonthlyReportModel({
    required this.monthKey,
    required this.managerName,
    required this.totalMembers,
    required this.totalDayMeals,
    required this.totalNightMeals,
    required this.totalMeals,
    required this.totalDeposit,
    required this.totalRegularCost,
    required this.totalExtraBill,
    required this.totalCost,
    required this.mealRate,
    required this.remainingBalance,
    this.totalDuesFromMembers = 0.0,
    this.totalSurplusOfMembers = 0.0,
    required this.memberReports,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'monthKey': monthKey,
      'managerName': managerName,
      'totalMembers': totalMembers,
      'totalDayMeals': totalDayMeals,
      'totalNightMeals': totalNightMeals,
      'totalMeals': totalMeals,
      'totalDeposit': totalDeposit,
      'totalRegularCost': totalRegularCost,
      'totalExtraBill': totalExtraBill,
      'totalCost': totalCost,
      'mealRate': mealRate,
      'remainingBalance': remainingBalance,
      'totalDuesFromMembers': totalDuesFromMembers,
      'totalSurplusOfMembers': totalSurplusOfMembers,
      'memberReports': memberReports.map((e) => e.toMap()).toList(),
      'generatedAt': Timestamp.fromDate(generatedAt),
    };
  }

  factory MonthlyReportModel.fromMap(Map<String, dynamic> map) {
    final reportsList = (map['memberReports'] as List? ?? [])
        .map((e) => MemberReportItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return MonthlyReportModel(
      monthKey: map['monthKey'] ?? '',
      managerName: map['managerName'] ?? '',
      totalMembers: (map['totalMembers'] as num?)?.toInt() ?? 0,
      totalDayMeals: (map['totalDayMeals'] as num?)?.toDouble() ?? 0.0,
      totalNightMeals: (map['totalNightMeals'] as num?)?.toDouble() ?? 0.0,
      totalMeals: (map['totalMeals'] as num?)?.toDouble() ?? 0.0,
      totalDeposit: (map['totalDeposit'] as num?)?.toDouble() ?? 0.0,
      totalRegularCost: (map['totalRegularCost'] as num?)?.toDouble() ?? 0.0,
      totalExtraBill: (map['totalExtraBill'] as num?)?.toDouble() ?? 0.0,
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0.0,
      mealRate: (map['mealRate'] as num?)?.toDouble() ?? 0.0,
      remainingBalance: (map['remainingBalance'] as num?)?.toDouble() ?? 0.0,
      totalDuesFromMembers: (map['totalDuesFromMembers'] as num?)?.toDouble() ?? 0.0,
      totalSurplusOfMembers: (map['totalSurplusOfMembers'] as num?)?.toDouble() ?? 0.0,
      memberReports: reportsList,
      generatedAt: (map['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
