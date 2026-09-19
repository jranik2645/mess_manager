import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/manager_model.dart';
import '../models/member_model.dart';
import '../models/meal_model.dart';
import '../models/deposit_model.dart';
import '../models/cost_model.dart';
import '../models/extra_bill_model.dart';
import '../models/report_model.dart';
import '../utils/app_constants.dart';
import '../utils/formatters.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore? _firestore;
  final RxBool isFirebaseReady = false.obs;

  // demo mode data
  final List<MemberModel> _demoMembers = [];
  ManagerModel? _demoManager;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        
        // Enable offline persistence only once
        _firestore!.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );

        // Simple connectivity check
        await _firestore!.collection('health_check').limit(1).get().timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('Firebase connection timeout'),
        );
        isFirebaseReady.value = true;
        debugPrint('FirestoreService: Connected successfully.');
      }
    } catch (e) {
      debugPrint('FirestoreService Error: $e');
      isFirebaseReady.value = false;
      _seedDemoData();
    }
  }

  void _seedDemoData() {
    if (_demoMembers.isNotEmpty) return;
    _demoManager = ManagerModel(id: 'mgr_01', name: 'ডেমো ম্যানেজার', phone: '01700', joiningDate: DateTime.now());
    _demoMembers.addAll([
      MemberModel(id: 'mem_1', name: 'আব্দুর রহিম', phone: '01712', roomNumber: '১০১', joiningDate: DateTime.now()),
      MemberModel(id: 'mem_2', name: 'তানভীর করিম', phone: '01812', roomNumber: '১০২', joiningDate: DateTime.now()),
    ]);
  }

  // ===================== MANAGER =====================
  Stream<ManagerModel?> getManagerStream() {
    if (_firestore != null) {
      return _firestore!
          .collection(AppConstants.colManagers)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return ManagerModel.fromMap(snapshot.docs.first.data(), docId: snapshot.docs.first.id);
        }
        return null;
      });
    }
    return Stream.value(_demoManager);
  }

  Future<void> saveManager(ManagerModel manager) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colManagers).doc(manager.id).set(manager.toMap(), SetOptions(merge: true));
    }
  }

  // ===================== MEMBERS =====================
  Stream<List<MemberModel>> getMembersStream() {
    if (_firestore != null) {
      return _firestore!
          .collection(AppConstants.colMembers)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => MemberModel.fromMap(doc.data(), docId: doc.id)).toList());
    }
    return Stream.value(_demoMembers);
  }

  Future<void> addMember(MemberModel member) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colMembers).doc(member.id).set(member.toMap());
    }
  }

  Future<void> updateMember(MemberModel member) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colMembers).doc(member.id).update(member.toMap());
    }
  }

  Future<void> deleteMember(String memberId) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colMembers).doc(memberId).delete();
    }
  }

  // ===================== DEPOSITS =====================
  Stream<List<DepositModel>> getDepositsStream(String monthKey) {
    if (_firestore != null) {
      return _firestore!
          .collection(AppConstants.colDeposits)
          .where('monthKey', isEqualTo: monthKey)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => DepositModel.fromMap(doc.data(), docId: doc.id)).toList());
    }
    return Stream.value([]);
  }

  Future<void> addDeposit(DepositModel deposit) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colDeposits).doc(deposit.id).set(deposit.toMap());
    }
  }

  Future<void> updateDeposit(DepositModel deposit) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colDeposits).doc(deposit.id).update(deposit.toMap());
    }
  }

  Future<void> deleteDeposit(String depositId, String monthKey) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colDeposits).doc(depositId).delete();
    }
  }

  // ===================== COSTS =====================
  Stream<List<CostModel>> getCostsStream(String monthKey) {
    if (_firestore != null) {
      return _firestore!
          .collection(AppConstants.colCosts)
          .where('monthKey', isEqualTo: monthKey)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => CostModel.fromMap(doc.data(), docId: doc.id)).toList());
    }
    return Stream.value([]);
  }

  Future<void> addCost(CostModel cost) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colCosts).doc(cost.id).set(cost.toMap());
    }
  }

  Future<void> updateCost(CostModel cost) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colCosts).doc(cost.id).update(cost.toMap());
    }
  }

  Future<void> deleteCost(String costId, String monthKey) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colCosts).doc(costId).delete();
    }
  }

  // ===================== MEALS =====================
  Stream<List<MealModel>> getMealsStream(String monthKey) {
    if (_firestore != null) {
      return _firestore!
          .collection(AppConstants.colMeals)
          .where('monthKey', isEqualTo: monthKey)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => MealModel.fromMap(doc.data(), docId: doc.id)).toList());
    }
    return Stream.value([]);
  }

  Future<void> setMeal(MealModel meal) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colMeals).doc(meal.id).set(meal.toMap(), SetOptions(merge: true));
    }
  }

  // ===================== EXTRA BILLS =====================
  Stream<List<ExtraBillModel>> getExtraBillsStream(String monthKey) {
    if (_firestore != null) {
      return _firestore!
          .collection(AppConstants.colExtraBills)
          .where('monthKey', isEqualTo: monthKey)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => ExtraBillModel.fromMap(doc.data(), docId: doc.id)).toList());
    }
    return Stream.value([]);
  }

  Future<void> addExtraBill(ExtraBillModel extraBill) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colExtraBills).doc(extraBill.id).set(extraBill.toMap());
    }
  }

  Future<void> updateExtraBill(ExtraBillModel extraBill) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colExtraBills).doc(extraBill.id).update(extraBill.toMap());
    }
  }

  Future<void> deleteExtraBill(String billId, String monthKey) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colExtraBills).doc(billId).delete();
    }
  }

  // ===================== DATA RESET =====================
  Future<void> clearAllMessData() async {
    if (_firestore == null) return;

    final collections = [
      AppConstants.colMembers,
      AppConstants.colMeals,
      AppConstants.colDeposits,
      AppConstants.colCosts,
      AppConstants.colExtraBills,
      AppConstants.colMonthlyReports,
    ];

    try {
      for (final col in collections) {
        final snapshots = await _firestore!.collection(col).get();
        for (final doc in snapshots.docs) {
          await doc.reference.delete();
        }
      }
      debugPrint('All mess data cleared for new manager.');
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  // ===================== REPORTS =====================
  Future<void> saveMonthlyReport(MonthlyReportModel report) async {
    if (_firestore != null) {
      await _firestore!
          .collection(AppConstants.colMonthlyReports)
          .doc(report.monthKey)
          .set(report.toMap(), SetOptions(merge: true));
    }
  }

  Future<MonthlyReportModel?> getMonthlyReport(String monthKey) async {
    if (_firestore != null) {
      final doc = await _firestore!.collection(AppConstants.colMonthlyReports).doc(monthKey).get();
      if (doc.exists && doc.data() != null) {
        return MonthlyReportModel.fromMap(doc.data()!);
      }
    }
    return null;
  }
}
