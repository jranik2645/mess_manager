import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mess_manager/models/meal_model.dart';
import 'package:mess_manager/models/member_model.dart';
import 'package:mess_manager/widgets/custom_button.dart';
import 'package:mess_manager/widgets/meal_counter_tile.dart';
import 'package:mess_manager/widgets/summary_card.dart';

void main() {
  testWidgets('SummaryCard renders title, value, and subtitle properly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SummaryCard(
            title: 'মোট মিল',
            value: '১২৫.০',
            subtitle: 'দিনের মিল: ৬৫ | রাতের মিল: ৬০',
            icon: Icons.restaurant,
          ),
        ),
      ),
    );

    expect(find.text('মোট মিল'), findsOneWidget);
    expect(find.text('১২৫.০'), findsOneWidget);
    expect(find.text('দিনের মিল: ৬৫ | রাতের মিল: ৬০'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
  });

  testWidgets('MealCounterTile renders member and meal counters with + and -', (
    WidgetTester tester,
  ) async {
    final member = MemberModel(
      id: 'm1',
      name: 'তানভীর করিম',
      phone: '01711111111',
      roomNumber: '১০১',
      joiningDate: DateTime(2026, 9, 1),
    );

    final meal = MealModel(
      id: '2026-09_2026-09-16_m1',
      date: '2026-09-16',
      monthKey: '2026-09',
      memberId: 'm1',
      memberName: 'তানভীর করিম',
      dayMeal: 1.0,
      nightMeal: 1.0,
    );

    double dayDelta = 0.0;
    double nightDelta = 0.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MealCounterTile(
            member: member,
            meal: meal,
            onDayMealChange: (delta) => dayDelta = delta,
            onNightMealChange: (delta) => nightDelta = delta,
          ),
        ),
      ),
    );

    expect(find.text('তানভীর করিম'), findsOneWidget);
    expect(find.text('রুম: ১০১'), findsOneWidget);
    expect(find.text('মোট: 2'), findsOneWidget);

    // Tap + icon for day meal
    final addButtons = find.byIcon(Icons.add);
    expect(addButtons, findsNWidgets(2)); // Day and Night plus buttons

    await tester.tap(addButtons.first);
    expect(dayDelta, 1.0);

    await tester.tap(addButtons.last);
    expect(nightDelta, 1.0);
  });

  testWidgets(
    'CustomButton defaults to full width when no explicit width is passed',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomButton(text: 'Submit', onPressed: () {}),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(CustomButton),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.width, double.infinity);
    },
  );
}
