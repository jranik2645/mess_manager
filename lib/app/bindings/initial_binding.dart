import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/auth_manager_controller.dart';
import '../../controllers/member_controller.dart';
import '../../controllers/meal_controller.dart';
import '../../controllers/deposit_controller.dart';
import '../../controllers/cost_controller.dart';
import '../../controllers/extra_bill_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/report_controller.dart';
import '../../controllers/navigation_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<AuthManagerController>(AuthManagerController(), permanent: true);
    Get.put<MemberController>(MemberController(), permanent: true);
    Get.put<MealController>(MealController(), permanent: true);
    Get.put<DepositController>(DepositController(), permanent: true);
    Get.put<CostController>(CostController(), permanent: true);
    Get.put<ExtraBillController>(ExtraBillController(), permanent: true);
    Get.put<DashboardController>(DashboardController(), permanent: true);
    Get.put<ReportController>(ReportController(), permanent: true);
  }
}

