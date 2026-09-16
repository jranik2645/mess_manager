import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_manager_controller.dart';
import '../../controllers/meal_controller.dart';
import '../../controllers/member_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/meal_counter_tile.dart';
import '../../widgets/empty_state_widget.dart';
import '../../app/routes/app_routes.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  Future<void> _selectDate(BuildContext context, MealController mealCtrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: mealCtrl.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      mealCtrl.changeDate(picked);
    }
  }

  void _showBulkActionSheet(BuildContext context, MealController mealCtrl, MemberController memberCtrl) {
    final active = memberCtrl.activeMembers;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'দ্রুত মিল সেট করুন (Quick Meal Setup)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.dayMeal,
                  child: Icon(Icons.check, color: Colors.white, size: 20),
                ),
                title: const Text('সকলের ১ দিন + ১ রাতের মিল চালু'),
                subtitle: Text('মোট ${active.length} জন সক্রিয় সদস্য'),
                onTap: () {
                  Navigator.pop(ctx);
                  mealCtrl.setAllActiveMeals(activeMembers: active, dayMeal: 1, nightMeal: 1);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade600,
                  child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 20),
                ),
                title: const Text('শুধুমাত্র ১ দুপুরের মিল চালু (রাত বন্ধ)'),
                onTap: () {
                  Navigator.pop(ctx);
                  mealCtrl.setAllActiveMeals(activeMembers: active, dayMeal: 1, nightMeal: 0);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade600,
                  child: const Icon(Icons.nightlight_round, color: Colors.white, size: 20),
                ),
                title: const Text('শুধুমাত্র ১ রাতের মিল চালু (দুপুর বন্ধ)'),
                onTap: () {
                  Navigator.pop(ctx);
                  mealCtrl.setAllActiveMeals(activeMembers: active, dayMeal: 0, nightMeal: 1);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade600,
                  child: const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
                ),
                title: const Text('গতকালকের মিল তালিকা থেকে কপি করুন'),
                subtitle: const Text('হুবহু গতকালের হিসাব আজকের দিনে বসবে'),
                onTap: () {
                  Navigator.pop(ctx);
                  mealCtrl.copyFromYesterday(active);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade400,
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
                title: const Text('আজকের দিনের সকল মিল বন্ধ (০) করুন'),
                onTap: () {
                  Navigator.pop(ctx);
                  mealCtrl.setAllActiveMeals(activeMembers: active, dayMeal: 0, nightMeal: 0);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealCtrl = Get.find<MealController>();
    final memberCtrl = Get.find<MemberController>();
    final authCtrl = Get.find<AuthManagerController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('দৈনিক মিল শিট (Meals)'),
        actions: [
          if (authCtrl.isLoggedIn.value)
            IconButton(
              icon: const Icon(Icons.flash_on_rounded, color: Colors.amberAccent),
              tooltip: 'কুইক মিল অ্যাকশন',
              onPressed: () => _showBulkActionSheet(context, mealCtrl, memberCtrl),
            ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Day Button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                  tooltip: 'পূর্ববর্তী দিন',
                  onPressed: () {
                    final prev = mealCtrl.selectedDate.value.subtract(const Duration(days: 1));
                    mealCtrl.changeDate(prev);
                  },
                ),
                // Date Display & Picker trigger
                InkWell(
                  onTap: () => _selectDate(context, mealCtrl),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Obx(
                      () => Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            AppFormatters.formatDateWithDay(mealCtrl.selectedDate.value),
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                // Next Day Button
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  tooltip: 'পরবর্তী দিন',
                  onPressed: () {
                    final next = mealCtrl.selectedDate.value.add(const Duration(days: 1));
                    mealCtrl.changeDate(next);
                  },
                ),
              ],
            ),
          ),

          // Daily Total Summary Strip
          Obx(() {
            final day = mealCtrl.todayTotalDayMeals;
            final night = mealCtrl.todayTotalNightMeals;
            final total = mealCtrl.todayTotalMeals;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: isDark ? const Color(0xFF252525) : const Color(0xFFF1F5F9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _mealStatBadge(
                    icon: Icons.wb_sunny_rounded,
                    label: 'দুপুর:',
                    value: AppFormatters.formatMeal(day),
                    color: AppColors.dayMeal,
                  ),
                  Container(height: 20, width: 1, color: Colors.grey.shade400),
                  _mealStatBadge(
                    icon: Icons.nightlight_round,
                    label: 'রাত:',
                    value: AppFormatters.formatMeal(night),
                    color: AppColors.nightMeal,
                  ),
                  Container(height: 20, width: 1, color: Colors.grey.shade400),
                  _mealStatBadge(
                    icon: Icons.restaurant_rounded,
                    label: 'আজকের মোট:',
                    value: AppFormatters.formatMeal(total),
                    color: AppColors.primary,
                    isBold: true,
                  ),
                ],
              ),
            );
          }),

          // Members Meal List
          Expanded(
            child: Obx(() {
              final activeMembers = memberCtrl.activeMembers;

              if (activeMembers.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: 'কোনো সক্রিয় মেম্বার নেই',
                  message: 'মিল যোগ করার জন্য প্রথমে মেম্বার তালিকায় সদস্য যোগ করুন।',
                  actionText: 'সদস্য যোগ করুন',
                  onAction: () => Get.toNamed(AppRoutes.members),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: activeMembers.length,
                itemBuilder: (context, index) {
                  final member = activeMembers[index];
                  final meal = mealCtrl.getMealForMember(member.id, member.name);

                  return MealCounterTile(
                    member: member,
                    meal: meal,
                    isReadOnly: !authCtrl.isLoggedIn.value,
                    onDayMealChange: (delta) {
                      mealCtrl.updateDayMeal(member, delta);
                    },
                    onNightMealChange: (delta) {
                      mealCtrl.updateNightMeal(member, delta);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: authCtrl.isLoggedIn.value
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.flash_on),
              label: const Text('এক ক্লিকে সেট'),
              onPressed: () => _showBulkActionSheet(context, mealCtrl, memberCtrl),
            )
          : null,
    );
  }

  Widget _mealStatBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

