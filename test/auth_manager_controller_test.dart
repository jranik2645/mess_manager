import 'package:flutter_test/flutter_test.dart';
import 'package:mess_manager/controllers/auth_manager_controller.dart';
import 'package:mess_manager/models/manager_model.dart';

void main() {
  group('AuthManagerController', () {
    test('syncLoginState clears auth when manager is null', () {
      final controller = AuthManagerController();

      controller.currentManager.value = ManagerModel(
        id: 'mgr_1',
        name: 'Test Manager',
        phone: '01712345678',
        joiningDate: DateTime(2026, 9, 1),
      );
      controller.isLoggedIn.value = true;

      controller.syncLoginState(null);

      expect(controller.currentManager.value, isNull);
      expect(controller.isLoggedIn.value, isFalse);
    });
  });
}
