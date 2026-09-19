import 'package:flutter/material.dart';
import '../models/member_model.dart';
import '../models/meal_model.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';

class MealCounterTile extends StatelessWidget {
  final MemberModel member;
  final MealModel meal;
  final bool isReadOnly;
  final Function(double delta) onDayMealChange;
  final Function(double delta) onNightMealChange;

  const MealCounterTile({
    super.key,
    required this.member,
    required this.meal,
    this.isReadOnly = false,
    required this.onDayMealChange,
    required this.onNightMealChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withAlpha(20),
                  child: Text(
                    member.name.isNotEmpty ? member.name[0] : 'M',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ব্যালেন্স: ${AppFormatters.formatCurrency(member.balance)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: member.balance < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'মোট: ${AppFormatters.formatMeal(meal.totalMeal)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _counter(
                    context: context,
                    label: 'দুপুর',
                    icon: Icons.wb_sunny_rounded,
                    color: AppColors.dayMeal,
                    value: meal.dayMeal,
                    onChanged: onDayMealChange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _counter(
                    context: context,
                    label: 'রাত',
                    icon: Icons.nightlight_round,
                    color: AppColors.nightMeal,
                    value: meal.nightMeal,
                    onChanged: onNightMealChange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _counter({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required double value,
    required Function(double) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262626) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value > 0 ? color.withAlpha(100) : Colors.transparent),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btn(Icons.remove, () => onChanged(-1), !isReadOnly && value > 0),
              Text(
                AppFormatters.formatMeal(value),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _btn(Icons.add, () => onChanged(1), !isReadOnly),
            ],
          ),
          if (!isReadOnly)
            TextButton(
              onPressed: () => onChanged(value % 1 != 0 ? -0.5 : 0.5),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text(value % 1 != 0 ? '-০.৫' : '+০.৫', style: TextStyle(fontSize: 10, color: color)),
            ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, bool enabled) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 20),
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: enabled ? AppColors.primary.withAlpha(20) : Colors.transparent,
      ),
    );
  }
}
