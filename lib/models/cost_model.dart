import 'package:cloud_firestore/cloud_firestore.dart';

class CostModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String monthKey;
  final String category;
  final String addedBy;
  final String note;
  final DateTime createdAt;

  CostModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.monthKey,
    this.category = 'Food (সাধারণ বাজার)',
    this.addedBy = '',
    this.note = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  CostModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? monthKey,
    String? category,
    String? addedBy,
    String? note,
    DateTime? createdAt,
  }) {
    return CostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      monthKey: monthKey ?? this.monthKey,
      category: category ?? this.category,
      addedBy: addedBy ?? this.addedBy,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'monthKey': monthKey,
      'category': category,
      'addedBy': addedBy,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CostModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return CostModel(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: parseDate(map['date']),
      monthKey: map['monthKey'] ?? '',
      category: map['category'] ?? 'Food (সাধারণ বাজার)',
      addedBy: map['addedBy'] ?? '',
      note: map['note'] ?? '',
      createdAt: parseDate(map['createdAt']),
    );
  }
}

