import 'package:flutter_test/flutter_test.dart';
import 'package:mess_manager/models/member_model.dart';
import 'package:mess_manager/models/meal_model.dart';
import 'package:mess_manager/models/deposit_model.dart';
import 'package:mess_manager/models/cost_model.dart';
import 'package:mess_manager/models/extra_bill_model.dart';
import 'package:mess_manager/services/calculation_service.dart';

void main() {
  group('CalculationService Unit Tests', () {
    final member1 = MemberModel(
      id: 'm1',
      name: 'Rahim',
      phone: '01711111111',
      joiningDate: DateTime(2026, 9, 1),
    );
    final member2 = MemberModel(
      id: 'm2',
      name: 'Karim',
      phone: '01722222222',
      joiningDate: DateTime(2026, 9, 1),
    );

    test('calculates total day, night, and total meals correctly', () {
      final meals = [
        MealModel(id: '1', date: '2026-09-01', monthKey: '2026-09', memberId: 'm1', memberName: 'Rahim', dayMeal: 1.5, nightMeal: 1.0),
        MealModel(id: '2', date: '2026-09-01', monthKey: '2026-09', memberId: 'm2', memberName: 'Karim', dayMeal: 2.0, nightMeal: 0.5),
      ];

      expect(CalculationService.calculateTotalDayMeals(meals), 3.5);
      expect(CalculationService.calculateTotalNightMeals(meals), 1.5);
      expect(CalculationService.calculateTotalMeals(meals), 5.0);
    });

    test('calculates meal rate correctly and handles 0 meals safely', () {
      expect(CalculationService.calculateMealRate(2500, 50), 50.0);
      expect(CalculationService.calculateMealRate(1000, 0), 0.0);
    });

    test('calculates deposits, expenditures, and remaining mess balance', () {
      final deposits = [
        DepositModel(id: 'd1', memberId: 'm1', memberName: 'Rahim', amount: 3000, date: DateTime(2026, 9, 1), monthKey: '2026-09'),
        DepositModel(id: 'd2', memberId: 'm2', memberName: 'Karim', amount: 3000, date: DateTime(2026, 9, 1), monthKey: '2026-09'),
      ];
      final costs = [
        CostModel(id: 'c1', title: 'Rice', amount: 1500, date: DateTime(2026, 9, 1), monthKey: '2026-09'),
        CostModel(id: 'c2', title: 'Meat', amount: 1500, date: DateTime(2026, 9, 2), monthKey: '2026-09'),
      ];
      final extraBills = [
        ExtraBillModel(
          id: 'b1',
          title: 'WiFi',
          category: 'WiFi Bill',
          amount: 800,
          date: DateTime(2026, 9, 1),
          monthKey: '2026-09',
          distributionType: 'equal',
          memberShares: {'m1': 400, 'm2': 400},
        ),
      ];

      final totalDep = CalculationService.calculateTotalDeposits(deposits);
      final totalRegular = CalculationService.calculateTotalRegularCosts(costs);
      final totalExtra = CalculationService.calculateTotalExtraBills(extraBills);
      final totalCost = CalculationService.calculateTotalExpenditure(totalRegular, totalExtra);
      final remaining = CalculationService.calculateRemainingBalance(
        totalDeposit: totalDep,
        totalRegularCost: totalRegular,
        totalExtraBill: totalExtra,
      );

      expect(totalDep, 6000.0);
      expect(totalRegular, 3000.0);
      expect(totalExtra, 800.0);
      expect(totalCost, 3800.0);
      expect(remaining, 2200.0);
    });

    test('distributes extra bill equally among members', () {
      final shares = CalculationService.distributeExtraBill(
        totalAmount: 1000,
        distributionType: 'equal',
        activeMembers: [member1, member2],
      );

      expect(shares['m1'], 500.0);
      expect(shares['m2'], 500.0);
    });

    test('generates full monthly audit report and member balances', () {
      final meals = [
        MealModel(id: '1', date: '2026-09-01', monthKey: '2026-09', memberId: 'm1', memberName: 'Rahim', dayMeal: 10, nightMeal: 10), // 20 meals
        MealModel(id: '2', date: '2026-09-01', monthKey: '2026-09', memberId: 'm2', memberName: 'Karim', dayMeal: 15, nightMeal: 15), // 30 meals
      ];
      final deposits = [
        DepositModel(id: 'd1', memberId: 'm1', memberName: 'Rahim', amount: 3000, date: DateTime(2026, 9, 1), monthKey: '2026-09'),
        DepositModel(id: 'd2', memberId: 'm2', memberName: 'Karim', amount: 3000, date: DateTime(2026, 9, 1), monthKey: '2026-09'),
      ];
      final costs = [
        CostModel(id: 'c1', title: 'Food', amount: 2500, date: DateTime(2026, 9, 1), monthKey: '2026-09'),
      ]; // total meals: 50 -> meal rate: 2500 / 50 = 50 TK
      final extraBills = [
        ExtraBillModel(
          id: 'b1',
          title: 'Current',
          category: 'Electricity',
          amount: 600,
          date: DateTime(2026, 9, 1),
          monthKey: '2026-09',
          distributionType: 'equal',
          memberShares: {'m1': 300, 'm2': 300},
        ),
      ];

      final report = CalculationService.generateMonthlyReport(
        monthKey: '2026-09',
        managerName: 'Test Manager',
        members: [member1, member2],
        meals: meals,
        deposits: deposits,
        costs: costs,
        extraBills: extraBills,
      );

      expect(report.totalMeals, 50.0);
      expect(report.mealRate, 50.0);
      expect(report.totalCost, 3100.0);
      expect(report.remainingBalance, 2900.0);

      final r1 = report.memberReports.firstWhere((r) => r.memberId == 'm1');
      // Rahim: 20 meals * 50 = 1000 meal cost + 300 extra = 1300 total cost. Deposit: 3000. Balance: 1700 (positive)
      expect(r1.mealCost, 1000.0);
      expect(r1.totalCost, 1300.0);
      expect(r1.balance, 1700.0);
      expect(r1.balanceStatus, contains('জমা'));

      final r2 = report.memberReports.firstWhere((r) => r.memberId == 'm2');
      // Karim: 30 meals * 50 = 1500 meal cost + 300 extra = 1800 total cost. Deposit: 3000. Balance: 1200 (positive)
      expect(r2.mealCost, 1500.0);
      expect(r2.totalCost, 1800.0);
      expect(r2.balance, 1200.0);
    });
  });
}

