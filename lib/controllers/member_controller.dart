import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/member_model.dart';
import '../services/firestore_service.dart';

class MemberController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  final RxList<MemberModel> members = <MemberModel>[].obs;
  final RxList<MemberModel> filteredMembers = <MemberModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs; // 'all', 'active', 'inactive'
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _bindMembers();
  }

  void _bindMembers() {
    members.bindStream(_firestoreService.getMembersStream());
    ever(members, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());
    ever(statusFilter, (_) => applyFilters());
  }

  void applyFilters() {
    List<MemberModel> list = List.from(members);

    // Filter by status
    if (statusFilter.value != 'all') {
      list = list.where((m) => m.status.toLowerCase() == statusFilter.value).toList();
    }

    // Filter by search query (name, phone, room)
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      list = list.where((m) {
        final matchName = m.name.toLowerCase().contains(query);
        final matchPhone = m.phone.contains(query);
        final matchRoom = m.roomNumber.toLowerCase().contains(query);
        return matchName || matchPhone || matchRoom;
      }).toList();
    }

    filteredMembers.assignAll(list);
  }

  List<MemberModel> get activeMembers {
    return members.where((m) => m.isActive).toList();
  }

  Future<bool> addMember({
    required String name,
    required String phone,
    String? id, // Optional ID to prevent duplicates
    String email = '',
    String roomNumber = '',
    DateTime? joiningDate,
    String status = 'active',
  }) async {
    try {
      isLoading.value = true;
      final newMember = MemberModel(
        id: id ?? 'mem_${_uuid.v4().substring(0, 8)}',
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim(),
        roomNumber: roomNumber.trim(),
        joiningDate: joiningDate ?? DateTime.now(),
        status: status,
      );

      await _firestoreService.addMember(newMember);
      Get.snackbar(
        'সফল',
        'নতুন মেম্বার "${newMember.name}" যোগ করা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'মেম্বার যোগ করা যায়নি: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMember(MemberModel updatedMember) async {
    try {
      isLoading.value = true;
      await _firestoreService.updateMember(updatedMember);
      Get.snackbar(
        'আপডেট সফল',
        'মেম্বার তথ্য সফলভাবে আপডেট হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade700,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'মেম্বার আপডেট করা যায়নি: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteMember(String memberId) async {
    try {
      isLoading.value = true;
      await _firestoreService.deleteMember(memberId);
      Get.snackbar(
        'মুছে ফেলা হয়েছে',
        'মেম্বার তালিকা থেকে মুছে ফেলা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'মেম্বার ডিলিট করা যায়নি: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  MemberModel? findMemberById(String id) {
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

