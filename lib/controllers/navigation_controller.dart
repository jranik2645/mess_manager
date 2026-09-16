import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxInt transactionSubTabIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  /// Jump to a specific tab and optionally a sub-tab
  void goToTab(int index, {int subIndex = 0}) {
    if (index == 3) {
      transactionSubTabIndex.value = subIndex;
    }
    currentIndex.value = index;
    
    if (Get.currentRoute != '/main' && Get.currentRoute != '/') {
      Get.until((route) => Get.currentRoute == '/main' || Get.currentRoute == '/');
    }
  }
}
