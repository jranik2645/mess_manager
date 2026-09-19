import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/manager_model.dart';
import '../services/firestore_service.dart';
import 'member_controller.dart';

class AuthManagerController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<ManagerModel?> currentManager = Rx<ManagerModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  bool _isSyncingManager = false;

  @override
  void onInit() {
    super.onInit();
    _checkInitialAuth();
    _bindManagerStream();
  }

  void _checkInitialAuth() {
    final user = _auth.currentUser;
    if (user != null) {
      isLoggedIn.value = true;
    }
  }

  void syncLoginState(ManagerModel? manager) {
    currentManager.value = manager;
    isLoggedIn.value = manager != null || _auth.currentUser != null;
    
    if (isLoggedIn.value && manager != null) {
      _ensureManagerIsMember(manager);
    }
  }

  /// Improved logic to prevent duplicate manager entries in member list
  Future<void> _ensureManagerIsMember(ManagerModel manager) async {
    if (_isSyncingManager) return;
    _isSyncingManager = true;

    try {
      final memberCtrl = Get.find<MemberController>();
      
      // Wait a bit to ensure member list is loaded from stream
      if (memberCtrl.members.isEmpty) {
        await Future.delayed(const Duration(seconds: 2));
      }

      final String managerMemberId = 'mgr_member_${manager.id}';
      
      // Strict check by ID or Phone to avoid any duplicates
      final existing = memberCtrl.members.firstWhereOrNull(
        (m) => m.id == managerMemberId || m.phone == manager.phone
      );
      
      if (existing == null) {
        await memberCtrl.addMember(
          id: managerMemberId,
          name: '${manager.name} (ম্যানেজার)',
          phone: manager.phone,
          email: manager.email,
          roomNumber: 'M-01',
        );
        debugPrint('Manager successfully linked as a member.');
      } else {
        // If name mismatch, update it
        if (existing.name != '${manager.name} (ম্যানেজার)') {
          final updated = existing.copyWith(name: '${manager.name} (ম্যানেজার)');
          await memberCtrl.updateMember(updated);
        }
      }
    } catch (e) {
      debugPrint('Manager sync error: $e');
    } finally {
      _isSyncingManager = false;
    }
  }

  void _bindManagerStream() {
    _firestoreService.getManagerStream().listen((manager) {
      syncLoginState(manager);
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user != null;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('ত্রুটি', e.message ?? 'লগইন ব্যর্থ');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> registerManager({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user != null) {
        await _firestoreService.clearAllMessData();
        final manager = ManagerModel(
          id: credential.user!.uid,
          name: name.trim(),
          phone: phone.trim(),
          email: email.trim(),
          joiningDate: DateTime.now(),
        );
        await _firestoreService.saveManager(manager);
        syncLoginState(manager);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'রেজিস্ট্রেশন ব্যর্থ');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveManagerProfile({required String name, required String phone, String email = '', DateTime? joiningDate}) async {
    try {
      isLoading.value = true;
      final existingId = currentManager.value?.id ?? _auth.currentUser?.uid ?? 'mgr_temp';
      final manager = ManagerModel(
        id: existingId,
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim(),
        joiningDate: joiningDate ?? DateTime.now(),
      );
      await _firestoreService.saveManager(manager);
      syncLoginState(manager);
      return true;
    } catch (e) { return false; }
    finally { isLoading.value = false; }
  }

  Future<void> logout() async {
    await _auth.signOut();
    currentManager.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed('/');
  }
}
