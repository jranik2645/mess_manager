import 'package:get/get.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/home/main_navigation_screen.dart';
import '../../screens/auth/manager_auth_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/meals/meals_screen.dart';
import '../../screens/members/members_list_screen.dart';
import '../../screens/transactions/transactions_screen.dart';
import '../../screens/reports/monthly_report_screen.dart';
import '../../screens/settings/settings_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.mainNav,
      page: () => const MainNavigationScreen(),
    ),
    GetPage(
      name: AppRoutes.managerAuth,
      page: () => ManagerAuthScreen(isEditing: Get.arguments == true),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.meals,
      page: () => const MealsScreen(),
    ),
    GetPage(
      name: AppRoutes.members,
      page: () => const MembersListScreen(),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => TransactionsScreen(initialTabIndex: (Get.arguments is int) ? Get.arguments : 0),
    ),
    GetPage(
      name: AppRoutes.report,
      page: () => const MonthlyReportScreen(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
    ),
  ];
}

