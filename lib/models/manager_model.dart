import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String imageUrl;
  final DateTime joiningDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ManagerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.imageUrl = '',
    required this.joiningDate,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ManagerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? imageUrl,
    DateTime? joiningDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ManagerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      joiningDate: joiningDate ?? this.joiningDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'imageUrl': imageUrl,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ManagerModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return ManagerModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      joiningDate: parseDate(map['joiningDate']),
      isActive: map['isActive'] ?? true,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}

