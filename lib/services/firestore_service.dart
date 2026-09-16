import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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

  // In-memory fallback caches if Firebase is in offline/demo mode
  final List<MemberModel> _demoMembers = [];
  final List<MealModel> _demoMeals = [];
  final List<DepositModel> _demoDeposits = [];
  final List<CostModel> _demoCosts = [];
  final List<ExtraBillModel> _demoExtraBills = [];
  ManagerModel? _demoManager;

  // StreamControllers for fallback demo mode
  final StreamController<ManagerModel?> _managerStreamCtrl = StreamController.broadcast();
  final StreamController<List<MemberModel>> _membersStreamCtrl = StreamController.broadcast();
  final StreamController<List<MealModel>> _mealsStreamCtrl = StreamController.broadcast();
  final StreamController<List<DepositModel>> _depositsStreamCtrl = StreamController.broadcast();
  final StreamController<List<CostModel>> _costsStreamCtrl = StreamController.broadcast();
  final StreamController<List<ExtraBillModel>> _extraBillsStreamCtrl = StreamController.broadcast();

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        
        // Enable offline persistence
        _firestore!.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );

        // Test connectivity briefly
        await _firestore!.collection('health_check').limit(1).get().timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw TimeoutException('Firebase connection timeout'),
        );
        isFirebaseReady.value = true;
        debugPrint('FirestoreService: Connected to Cloud Firestore with persistence enabled.');
      } else {
        isFirebaseReady.value = false;
        _seedDemoData();
      }
    } catch (e) {
      debugPrint('FirestoreService: Running in local fallback mode ($e)');
      isFirebaseReady.value = false;
      _seedDemoData();
    }
  }

  void _seedDemoData() {
    _demoMembers.clear();
    _demoMeals.clear();
    _demoDeposits.clear();
    _demoCosts.clear();
    _demoExtraBills.clear();

    final now = DateTime.now();
    final currentMonth = AppFormatters.getMonthKey(now);
    final todayDate = AppFormatters.getDateKey(now);

    _demoManager = ManagerModel(
      id: 'mgr_01',
      name: 'আরিফুল ইসলাম (ম্যানেজার)',
      phone: '01711000000',
      email: 'ariful.manager@gmail.com',
      joiningDate: DateTime(now.year, now.month, 1),
      isActive: true,
    );

    _demoMembers.addAll([
      MemberModel(
        id: 'mem_1',
        name: 'আব্দুর রহিম',
        phone: '01712345678',
        email: 'rahim@gmail.com',
        roomNumber: '১০১',
        joiningDate: DateTime(now.year, now.month, 1),
        status: 'active',
      ),
      MemberModel(
        id: 'mem_2',
        name: 'তানভীর করিম',
        phone: '01812345678',
        email: 'karim@gmail.com',
        roomNumber: '১০২',
        joiningDate: DateTime(now.year, now.month, 1),
        status: 'active',
      ),
      MemberModel(
        id: 'mem_3',
        name: 'সাকিব হাসান',
        phone: '01912345678',
        email: 'sakib@gmail.com',
        roomNumber: '১০৩',
        joiningDate: DateTime(now.year, now.month, 1),
        status: 'active',
      ),
      MemberModel(
        id: 'mem_4',
        name: 'মাহমুদ জামান',
        phone: '01612345678',
        email: 'zaman@gmail.com',
        roomNumber: '১০৪',
        joiningDate: DateTime(now.year, now.month, 1),
        status: 'active',
      ),
    ]);

    _demoDeposits.addAll([
      DepositModel(
        id: 'dep_1',
        memberId: 'mem_1',
        memberName: 'আব্দুর রহিম',
        amount: 3000,
        date: DateTime(now.year, now.month, 1),
        monthKey: currentMonth,
        paymentMethod: 'bKash (বিকাশ)',
        note: '১ম কিস্তি জমা',
      ),
      DepositModel(
        id: 'dep_2',
        memberId: 'mem_2',
        memberName: 'তানভীর করিম',
        amount: 3000,
        date: DateTime(now.year, now.month, 2),
        monthKey: currentMonth,
        paymentMethod: 'Nagad (নগদ অ্যাপ)',
        note: 'বিকাশ/নগদ ডিপোজিট',
      ),
      DepositModel(
        id: 'dep_3',
        memberId: 'mem_3',
        memberName: 'সাকিব হাসান',
        amount: 3500,
        date: DateTime(now.year, now.month, 2),
        monthKey: currentMonth,
        paymentMethod: 'Cash (নগদ)',
        note: 'নগদ ক্যাশ গ্রহণ',
      ),
      DepositModel(
        id: 'dep_4',
        memberId: 'mem_4',
        memberName: 'মাহমুদ জামান',
        amount: 3000,
        date: DateTime(now.year, now.month, 3),
        monthKey: currentMonth,
        paymentMethod: 'Bank (ব্যাংক ট্রান্সফার)',
        note: 'সিটি ব্যাংক ট্রান্সফার',
      ),
    ]);

    _demoCosts.addAll([
      CostModel(
        id: 'cost_1',
        title: 'চাল ও ডাল কেনা',
        amount: 1200,
        date: DateTime(now.year, now.month, 1),
        monthKey: currentMonth,
        category: 'Rice (চাল)',
        addedBy: 'ম্যানেজার',
        note: '২৫ কেজি চালের বস্তা',
      ),
      CostModel(
        id: 'cost_2',
        title: 'মুরগির মাংস ও মাছ',
        amount: 1550,
        date: DateTime(now.year, now.month, 2),
        monthKey: currentMonth,
        category: 'Meat (মাংস)',
        addedBy: 'ম্যানেজার',
        note: '৩ কেজি বয়লার ও রুই মাছ',
      ),
      CostModel(
        id: 'cost_3',
        title: 'সবজি ও ডিম',
        amount: 650,
        date: DateTime(now.year, now.month, 3),
        monthKey: currentMonth,
        category: 'Vegetable (শাক-সবজি)',
        addedBy: 'ম্যানেজার',
        note: '১ ডজন ডিম ও কাঁচাবাজার',
      ),
    ]);

    _demoExtraBills.addAll([
      ExtraBillModel(
        id: 'ext_1',
        title: 'ব্রডব্যান্ড ইন্টারনেট বিল',
        category: 'WiFi Bill (ইন্টারনেট)',
        amount: 800,
        date: DateTime(now.year, now.month, 5),
        monthKey: currentMonth,
        distributionType: 'equal',
        memberShares: {
          'mem_1': 200,
          'mem_2': 200,
          'mem_3': 200,
          'mem_4': 200,
        },
        description: 'অক্টোবর মাসের নেট সংযোগ',
        addedBy: 'ম্যানেজার',
      ),
      ExtraBillModel(
        id: 'ext_2',
        title: 'খালা / রান্নার বুয়ার বেতন',
        category: 'House Maid (খালা/বুয়ার বিল)',
        amount: 2000,
        date: DateTime(now.year, now.month, 5),
        monthKey: currentMonth,
        distributionType: 'equal',
        memberShares: {
          'mem_1': 500,
          'mem_2': 500,
          'mem_3': 500,
          'mem_4': 500,
        },
        description: 'মাসিক রান্নার বিল',
        addedBy: 'ম্যানেজার',
      ),
    ]);

    // Sample meals for today
    _demoMeals.addAll([
      MealModel(
        id: '${currentMonth}_${todayDate}_mem_1',
        date: todayDate,
        monthKey: currentMonth,
        memberId: 'mem_1',
        memberName: 'আব্দুর রহিম',
        dayMeal: 1,
        nightMeal: 1,
      ),
      MealModel(
        id: '${currentMonth}_${todayDate}_mem_2',
        date: todayDate,
        monthKey: currentMonth,
        memberId: 'mem_2',
        memberName: 'তানভীর করিম',
        dayMeal: 1,
        nightMeal: 2,
      ),
      MealModel(
        id: '${currentMonth}_${todayDate}_mem_3',
        date: todayDate,
        monthKey: currentMonth,
        memberId: 'mem_3',
        memberName: 'সাকিব হাসান',
        dayMeal: 2,
        nightMeal: 1,
      ),
      MealModel(
        id: '${currentMonth}_${todayDate}_mem_4',
        date: todayDate,
        monthKey: currentMonth,
        memberId: 'mem_4',
        memberName: 'মাহমুদ জামান',
        dayMeal: 1,
        nightMeal: 1,
      ),
    ]);
  }

  // ===================== MANAGER OPERATIONS =====================
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
    } else {
      Future.microtask(() => _managerStreamCtrl.add(_demoManager));
      return _managerStreamCtrl.stream;
    }
  }

  Future<void> saveManager(ManagerModel manager) async {
    if (_firestore != null) {
      await _firestore!
          .collection(AppConstants.colManagers)
          .doc(manager.id)
          .set(manager.toMap(), SetOptions(merge: true));
    } else {
      _demoManager = manager;
      _managerStreamCtrl.add(_demoManager);
    }
  }

  // ===================== MEMBERS OPERATIONS =====================
  Stream<List<MemberModel>> getMembersStream() {
    if (_firestore != null) {
      return _firestore!
          .collection(AppConstants.colMembers)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MemberModel.fromMap(doc.data(), docId: doc.id))
              .toList());
    } else {
      Future.microtask(() => _membersStreamCtrl.add(List.from(_demoMembers)));
      return _membersStreamCtrl.stream;
    }
  }

  Future<void> addMember(MemberModel member) async {
    if (_firestore != null) {
      await _firestore!
          .collection(AppConstants.colMembers)
          .doc(member.id)
          .set(member.toMap())
          .timeout(const Duration(seconds: 10));
    } else {
      _demoMembers.add(member);
      _membersStreamCtrl.add(List.from(_demoMembers));
    }
  }

  Future<void> updateMember(MemberModel member) async {
    if (_firestore != null) {
      await _firestore!
          .collection(AppConstants.colMembers)
          .doc(member.id)
          .update(member.toMap())
          .timeout(const Duration(seconds: 10));
    } else {
      final index = _demoMembers.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        _demoMembers[index] = member;
        _membersStreamCtrl.add(List.from(_demoMembers));
      }
    }
  }

  Future<void> deleteMember(String memberId) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colMembers).doc(memberId).delete();
    } else {
      _demoMembers.removeWhere((m) => m.id == memberId);
      _membersStreamCtrl.add(List.from(_demoMembers));
    }
  }

  // ===================== MEALS OPERATIONS =====================
  Stream<List<MealModel>> getMealsStream(String monthKey) {
    if (_firestore != null) {
      return _firestore!
          .collection(AppConstants.colMeals)
          .where('monthKey', isEqualTo: monthKey)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MealModel.fromMap(doc.data(), docId: doc.id))
              .toList());
    } else {
      final filtered = _demoMeals.where((m) => m.monthKey == monthKey).toList();
      Future.microtask(() => _mealsStreamCtrl.add(filtered));
      return _mealsStreamCtrl.stream;
    }
  }

  Future<void> setMeal(MealModel meal) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colMeals).doc(meal.id).set(meal.toMap(), SetOptions(merge: true));
    } else {
      final index = _demoMeals.indexWhere((m) => m.id == meal.id);
      if (index != -1) {
        _demoMeals[index] = meal;
      } else {
        _demoMeals.add(meal);
      }
      final filtered = _demoMeals.where((m) => m.monthKey == meal.monthKey).toList();
      _mealsStreamCtrl.add(filtered);
    }
  }

  Future<void> deleteMeal(String mealId, String monthKey) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colMeals).doc(mealId).delete();
    } else {
      _demoMeals.removeWhere((m) => m.id == mealId);
      final filtered = _demoMeals.where((m) => m.monthKey == monthKey).toList();
      _mealsStreamCtrl.add(filtered);
    }
  }

  // ===================== DEPOSIT OPERATIONS =====================
  Stream<List<DepositModel>> getDepositsStream(String monthKey) {
    if (_firestore != null) {
      return _firestore!
          .collection(AppConstants.colDeposits)
          .where('monthKey', isEqualTo: monthKey)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => DepositModel.fromMap(doc.data(), docId: doc.id))
              .toList());
    } else {
      final filtered = _demoDeposits.where((d) => d.monthKey == monthKey).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      Future.microtask(() => _depositsStreamCtrl.add(filtered));
      return _depositsStreamCtrl.stream;
    }
  }

  Future<void> addDeposit(DepositModel deposit) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colDeposits).doc(deposit.id).set(deposit.toMap());
    } else {
      _demoDeposits.add(deposit);
      final filtered = _demoDeposits.where((d) => d.monthKey == deposit.monthKey).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      _depositsStreamCtrl.add(filtered);
    }
  }

  Future<void> updateDeposit(DepositModel deposit) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colDeposits).doc(deposit.id).update(deposit.toMap());
    } else {
      final index = _demoDeposits.indexWhere((d) => d.id == deposit.id);
      if (index != -1) {
        _demoDeposits[index] = deposit;
        final filtered = _demoDeposits.where((d) => d.monthKey == deposit.monthKey).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        _depositsStreamCtrl.add(filtered);
      }
    }
  }

  Future<void> deleteDeposit(String depositId, String monthKey) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colDeposits).doc(depositId).delete();
    } else {
      _demoDeposits.removeWhere((d) => d.id == depositId);
      final filtered = _demoDeposits.where((d) => d.monthKey == monthKey).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      _depositsStreamCtrl.add(filtered);
    }
  }

  // ===================== REGULAR COST OPERATIONS =====================
  Stream<List<CostModel>> getCostsStream(String monthKey) {
    if (_firestore != null) {
      return _firestore!
          .collection(AppConstants.colCosts)
          .where('monthKey', isEqualTo: monthKey)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CostModel.fromMap(doc.data(), docId: doc.id))
              .toList());
    } else {
      final filtered = _demoCosts.where((c) => c.monthKey == monthKey).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      Future.microtask(() => _costsStreamCtrl.add(filtered));
      return _costsStreamCtrl.stream;
    }
  }

  Future<void> addCost(CostModel cost) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colCosts).doc(cost.id).set(cost.toMap());
    } else {
      _demoCosts.add(cost);
      final filtered = _demoCosts.where((c) => c.monthKey == cost.monthKey).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      _costsStreamCtrl.add(filtered);
    }
  }

  Future<void> updateCost(CostModel cost) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colCosts).doc(cost.id).update(cost.toMap());
    } else {
      final index = _demoCosts.indexWhere((c) => c.id == cost.id);
      if (index != -1) {
        _demoCosts[index] = cost;
        final filtered = _demoCosts.where((c) => c.monthKey == cost.monthKey).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        _costsStreamCtrl.add(filtered);
      }
    }
  }

  Future<void> deleteCost(String costId, String monthKey) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colCosts).doc(costId).delete();
    } else {
      _demoCosts.removeWhere((c) => c.id == costId);
      final filtered = _demoCosts.where((c) => c.monthKey == monthKey).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      _costsStreamCtrl.add(filtered);
    }
  }

  // ===================== EXTRA BILL OPERATIONS =====================
  Stream<List<ExtraBillModel>> getExtraBillsStream(String monthKey) {
    if (_firestore != null) {
      return _firestore!
          .collection(AppConstants.colExtraBills)
          .where('monthKey', isEqualTo: monthKey)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ExtraBillModel.fromMap(doc.data(), docId: doc.id))
              .toList());
    } else {
      final filtered = _demoExtraBills.where((b) => b.monthKey == monthKey).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      Future.microtask(() => _extraBillsStreamCtrl.add(filtered));
      return _extraBillsStreamCtrl.stream;
    }
  }

  Future<void> addExtraBill(ExtraBillModel extraBill) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colExtraBills).doc(extraBill.id).set(extraBill.toMap());
    } else {
      _demoExtraBills.add(extraBill);
      final filtered = _demoExtraBills.where((b) => b.monthKey == extraBill.monthKey).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      _extraBillsStreamCtrl.add(filtered);
    }
  }

  Future<void> updateExtraBill(ExtraBillModel extraBill) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colExtraBills).doc(extraBill.id).update(extraBill.toMap());
    } else {
      final index = _demoExtraBills.indexWhere((b) => b.id == extraBill.id);
      if (index != -1) {
        _demoExtraBills[index] = extraBill;
        final filtered = _demoExtraBills.where((b) => b.monthKey == extraBill.monthKey).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        _extraBillsStreamCtrl.add(filtered);
      }
    }
  }

  Future<void> deleteExtraBill(String billId, String monthKey) async {
    if (_firestore != null) {
      await _firestore!.collection(AppConstants.colExtraBills).doc(billId).delete();
    } else {
      _demoExtraBills.removeWhere((b) => b.id == billId);
      final filtered = _demoExtraBills.where((b) => b.monthKey == monthKey).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      _extraBillsStreamCtrl.add(filtered);
    }
  }

  // ===================== MONTHLY AUDIT / REPORT ARCHIVE =====================
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

