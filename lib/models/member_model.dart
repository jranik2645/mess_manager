import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String roomNumber;
  final DateTime joiningDate;
  final String status; // 'active' or 'inactive'
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Runtime computed cache for quick UI display
  double totalMeal;
  double totalDeposit;
  double totalCost;
  double balance;

  MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.roomNumber = '',
    required this.joiningDate,
    this.status = 'active',
    this.imageUrl = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.totalMeal = 0.0,
    this.totalDeposit = 0.0,
    this.totalCost = 0.0,
    this.balance = 0.0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isActive => status.toLowerCase() == 'active';

  MemberModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? roomNumber,
    DateTime? joiningDate,
    String? status,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalMeal,
    double? totalDeposit,
    double? totalCost,
    double? balance,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      roomNumber: roomNumber ?? this.roomNumber,
      joiningDate: joiningDate ?? this.joiningDate,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      totalMeal: totalMeal ?? this.totalMeal,
      totalDeposit: totalDeposit ?? this.totalDeposit,
      totalCost: totalCost ?? this.totalCost,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'roomNumber': roomNumber,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'status': status,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return MemberModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      joiningDate: parseDate(map['joiningDate']),
      status: map['status'] ?? 'active',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}

