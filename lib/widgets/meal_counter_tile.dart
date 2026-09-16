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
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            // Top Row: Member info & Total meals
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    member.name.isNotEmpty ? member.name[0] : 'M',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (member.roomNumber.isNotEmpty)
                        Text(
                          'রুম: ${member.roomNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                // Daily total badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: meal.totalMeal > 0
                        ? AppColors.primary.withAlpha(25)
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: meal.totalMeal > 0
                          ? AppColors.primary.withAlpha(80)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    'মোট: ${AppFormatters.formatMeal(meal.totalMeal)}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: meal.totalMeal > 0
                          ? AppColors.primary
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 18, thickness: 0.6),

            // Bottom Controls: Day Meal and Night Meal Counters
            Row(
              children: [
                // Day Meal Counter
                Expanded(
                  child: _buildMealCounter(
                    context: context,
                    label: 'দিনের মিল (দুপুর)',
                    icon: Icons.wb_sunny_rounded,
                    iconColor: AppColors.dayMeal,
                    count: meal.dayMeal,
                    onDecrease: () => onDayMealChange(-1.0),
                    onIncrease: () => onDayMealChange(1.0),
                    onHalfChange: (val) => onDayMealChange(val),
                  ),
                ),
                const SizedBox(width: 12),
                // Night Meal Counter
                Expanded(
                  child: _buildMealCounter(
                    context: context,
                    label: 'রাতের মিল',
                    icon: Icons.nightlight_round,
                    iconColor: AppColors.nightMeal,
                    count: meal.nightMeal,
                    onDecrease: () => onNightMealChange(-1.0),
                    onIncrease: () => onNightMealChange(1.0),
                    onHalfChange: (val) => onNightMealChange(val),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCounter({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color iconColor,
    required double count,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
    required Function(double) onHalfChange,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262626) : const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: count > 0 ? iconColor.withAlpha(90) : (isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minus button
              _counterButton(
                icon: Icons.remove,
                onTap: onDecrease,
                isEnabled: count > 0,
                color: Colors.red.shade400,
              ),
              // Meal value
              Text(
                AppFormatters.formatMeal(count),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: count > 0
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                ),
              ),
              // Plus button
              _counterButton(
                icon: Icons.add,
                onTap: onIncrease,
                isEnabled: true,
                color: Colors.green.shade600,
              ),
            ],
          ),
          // Half-meal (+0.5) quick pill
          if (!isReadOnly) ...[
            const SizedBox(height: 4),
            InkWell(
              onTap: () => onHalfChange(count % 1 != 0 ? -0.5 : 0.5),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  count % 1 != 0 ? 'হাফ বাদ (-০.৫)' : 'হাফ যোগ (+০.৫)',
                  style: TextStyle(
                    fontSize: 10,
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _counterButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (isEnabled && !isReadOnly) ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: (isEnabled && !isReadOnly) ? color.withAlpha(25) : Colors.grey.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: (isEnabled && !isReadOnly) ? color : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

