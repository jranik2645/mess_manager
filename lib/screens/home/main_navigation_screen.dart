import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation_controller.dart';
import '../dashboard/dashboard_screen.dart';
import '../meals/meals_screen.dart';
import '../members/members_list_screen.dart';
import '../transactions/transactions_screen.dart';
import '../reports/monthly_report_screen.dart';
import '../settings/settings_screen.dart';
import '../../utils/app_colors.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<NavigationController>();

    final List<Widget> screens = [
      const DashboardScreen(),
      const MealsScreen(),
      const MembersListScreen(),
      const TransactionsScreen(),
      const MonthlyReportScreen(),
      const SettingsScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;

        return Obx(() {
          // Explicitly access the observable value here so Obx tracks it
          final int currentIndex = navCtrl.currentIndex.value;

          if (isWideScreen) {
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: currentIndex,
                    onDestinationSelected: navCtrl.changeIndex,
                    labelType: NavigationRailLabelType.all,
                    selectedIconTheme: const IconThemeData(color: AppColors.primary),
                    selectedLabelTextStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Icon(Icons.restaurant_menu, size: 36, color: AppColors.primary),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: Text('ড্যাশবোর্ড'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.dinner_dining_outlined),
                        selectedIcon: Icon(Icons.dinner_dining),
                        label: Text('মিল শিট'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.people_alt_outlined),
                        selectedIcon: Icon(Icons.people_alt),
                        label: Text('সদস্য'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.account_balance_wallet_outlined),
                        selectedIcon: Icon(Icons.account_balance_wallet),
                        label: Text('লেনদেন'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.assignment_outlined),
                        selectedIcon: Icon(Icons.assignment),
                        label: Text('রিপোর্ট'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: Text('সেটিংস'),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(child: screens[currentIndex]),
                ],
              ),
            );
          }

          return Scaffold(
            body: IndexedStack(
              index: currentIndex,
              children: screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: navCtrl.changeIndex,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 11.5,
              unselectedFontSize: 11,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'ড্যাশবোর্ড',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.dinner_dining_outlined),
                  activeIcon: Icon(Icons.dinner_dining),
                  label: 'মিল',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_outlined),
                  activeIcon: Icon(Icons.people_alt),
                  label: 'সদস্য',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: 'লেনদেন',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment),
                  label: 'রিপোর্ট',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'সেটিংস',
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
