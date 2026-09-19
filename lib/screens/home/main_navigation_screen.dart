import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation_controller.dart';
import '../dashboard/dashboard_screen.dart';
import '../meals/meals_screen.dart';
import '../members/members_list_screen.dart';
import '../transactions/transactions_screen.dart';
import '../reports/monthly_report_screen.dart';
import '../settings/settings_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is found outside to be used in Obx
    final navCtrl = Get.find<NavigationController>();

    final List<Widget> screens = [
      const DashboardScreen(),
      const MealsScreen(),
      const MembersListScreen(),
      const TransactionsScreen(),
      const MonthlyReportScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Obx(() {
        // ESSENTIAL: Access .value to register dependency
        final index = navCtrl.currentIndex.value;
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 800;

            if (isWideScreen) {
              return Row(
                children: [
                  NavigationRail(
                    selectedIndex: index,
                    onDestinationSelected: navCtrl.changeIndex,
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('ড্যাশবোর্ড')),
                      NavigationRailDestination(icon: Icon(Icons.dinner_dining_outlined), selectedIcon: Icon(Icons.dinner_dining), label: Text('মিল শিট')),
                      NavigationRailDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people_alt), label: Text('সদস্য')),
                      NavigationRailDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: Text('লেনদেন')),
                      NavigationRailDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: Text('রিপোর্ট')),
                      NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('সেটিংস')),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(child: screens[index]),
                ],
              );
            }

            return IndexedStack(
              index: index,
              children: screens,
            );
          },
        );
      }),
      bottomNavigationBar: Obx(() {
        final index = navCtrl.currentIndex.value;
        return BottomNavigationBar(
          currentIndex: index,
          onTap: navCtrl.changeIndex,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'ড্যাশবোর্ড'),
            BottomNavigationBarItem(icon: Icon(Icons.dinner_dining_outlined), activeIcon: Icon(Icons.dinner_dining), label: 'মিল'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), activeIcon: Icon(Icons.people_alt), label: 'সদস্য'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'লেনদেন'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'রিপোর্ট'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'সেটিংস'),
          ],
        );
      }),
    );
  }
}
