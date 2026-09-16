import 'package:cloud_firestore/cloud_firestore.dart';

class MealModel {
  final String id;
  final String date; // Format: "YYYY-MM-DD"
  final String monthKey; // Format: "YYYY-MM"
  final String memberId;
  final String memberName;
  final double dayMeal;
  final double nightMeal;
  final DateTime updatedAt;

  MealModel({
    required this.id,
    required this.date,
    required this.monthKey,
    required this.memberId,
    required this.memberName,
    this.dayMeal = 0.0,
    this.nightMeal = 0.0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  double get totalMeal => dayMeal + nightMeal;

  MealModel copyWith({
    String? id,
    String? date,
    String? monthKey,
    String? memberId,
    String? memberName,
    double? dayMeal,
    double? nightMeal,
    DateTime? updatedAt,
  }) {
    return MealModel(
      id: id ?? this.id,
      date: date ?? this.date,
      monthKey: monthKey ?? this.monthKey,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      dayMeal: dayMeal ?? this.dayMeal,
      nightMeal: nightMeal ?? this.nightMeal,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'monthKey': monthKey,
      'memberId': memberId,
      'memberName': memberName,
      'dayMeal': dayMeal,
      'nightMeal': nightMeal,
      'totalMeal': totalMeal,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory MealModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return MealModel(
      id: docId ?? map['id'] ?? '',
      date: map['date'] ?? '',
      monthKey: map['monthKey'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      dayMeal: (map['dayMeal'] as num?)?.toDouble() ?? 0.0,
      nightMeal: (map['nightMeal'] as num?)?.toDouble() ?? 0.0,
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}

