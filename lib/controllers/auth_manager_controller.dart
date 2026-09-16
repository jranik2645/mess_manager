import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/manager_model.dart';
import '../services/firestore_service.dart';

class AuthManagerController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<ManagerModel?> currentManager = Rx<ManagerModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

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
  }

  void _bindManagerStream() {
    _firestoreService.getManagerStream().listen((manager) {
      syncLoginState(manager);
    });
  }

  /// Login with Email and Password
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user != null) {
        isLoggedIn.value = true;
        Get.snackbar(
          'সফল লগইন',
          'ম্যানেজার হিসেবে লগইন করা হয়েছে',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'লগইন ব্যর্থ হয়েছে';
      if (e.code == 'user-not-found') errorMessage = 'এই ইমেইলে কোনো একাউন্ট নেই';
      else if (e.code == 'wrong-password') errorMessage = 'ভুল পাসওয়ার্ড দিয়েছেন';
      else if (e.code == 'invalid-email') errorMessage = 'ভুল ইমেইল ফরম্যাট';

      Get.snackbar('ত্রুটি', errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'একটি অজানা সমস্যা হয়েছে: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Register Manager
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
        final manager = ManagerModel(
          id: credential.user!.uid,
          name: name.trim(),
          phone: phone.trim(),
          email: email.trim(),
          joiningDate: DateTime.now(),
          isActive: true,
        );

        await _firestoreService.saveManager(manager);
        syncLoginState(manager);
        
        Get.snackbar('সফল', 'ম্যানেজার একাউন্ট তৈরি করা হয়েছে',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade700,
            colorText: Colors.white);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'রেজিস্ট্রেশন ব্যর্থ হয়েছে';
      if (e.code == 'email-already-in-use') errorMessage = 'এই ইমেইলটি ইতিপূর্বেই ব্যবহার করা হয়েছে';
      else if (e.code == 'weak-password') errorMessage = 'পাসওয়ার্ডটি অন্তত ৬ ডিজিটের হতে হবে';
      else if (e.code == 'invalid-email') errorMessage = 'ভুল ইমেইল ফরম্যাট';

      Get.snackbar('ত্রুটি', errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'রেজিস্ট্রেশন সফল হয়নি: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Save or Update Manager Profile
  Future<bool> saveManagerProfile({
    required String name,
    required String phone,
    String email = '',
    String imageUrl = '',
    DateTime? joiningDate,
  }) async {
    try {
      isLoading.value = true;
      final existingId = (currentManager.value?.id.isNotEmpty == true)
          ? currentManager.value!.id
          : (_auth.currentUser?.uid ?? 'mgr_${DateTime.now().millisecondsSinceEpoch}');

      final manager = ManagerModel(
        id: existingId,
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim().isNotEmpty ? email.trim() : (currentManager.value?.email ?? ''),
        imageUrl: imageUrl.trim(),
        joiningDate: joiningDate ?? currentManager.value?.joiningDate ?? DateTime.now(),
        isActive: true,
      );

      await _firestoreService.saveManager(manager);
      syncLoginState(manager);

      Get.snackbar('সফল', 'ম্যানেজার তথ্য আপডেট করা হয়েছে', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'তথ্য সেভ করা যায়নি', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) return;
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      Get.snackbar('সফল', 'পাসওয়ার্ড রিসেট লিঙ্ক ইমেইলে পাঠানো হয়েছে', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('ত্রুটি', 'ইমেইল পাওয়া যায়নি', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      syncLoginState(null);
      Get.snackbar('লগআউট', 'সফলভাবে লগআউট করা হয়েছে', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
