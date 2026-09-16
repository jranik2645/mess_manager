import 'package:cloud_firestore/cloud_firestore.dart';

class ExtraBillModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String monthKey;
  final String distributionType; // 'equal', 'selected', 'manual'
  final Map<String, double> memberShares; // memberId -> assigned amount
  final String description;
  final String addedBy;
  final DateTime createdAt;

  ExtraBillModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.monthKey,
    this.distributionType = 'equal',
    required this.memberShares,
    this.description = '',
    this.addedBy = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ExtraBillModel copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    DateTime? date,
    String? monthKey,
    String? distributionType,
    Map<String, double>? memberShares,
    String? description,
    String? addedBy,
    DateTime? createdAt,
  }) {
    return ExtraBillModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      monthKey: monthKey ?? this.monthKey,
      distributionType: distributionType ?? this.distributionType,
      memberShares: memberShares ?? this.memberShares,
      description: description ?? this.description,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'monthKey': monthKey,
      'distributionType': distributionType,
      'memberShares': memberShares,
      'description': description,
      'addedBy': addedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ExtraBillModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    Map<String, double> parseShares(dynamic val) {
      if (val is Map) {
        return val.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
      }
      return {};
    }

    return ExtraBillModel(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'WiFi Bill (ইন্টারনেট)',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: parseDate(map['date']),
      monthKey: map['monthKey'] ?? '',
      distributionType: map['distributionType'] ?? 'equal',
      memberShares: parseShares(map['memberShares']),
      description: map['description'] ?? '',
      addedBy: map['addedBy'] ?? '',
      createdAt: parseDate(map['createdAt']),
    );
  }
}

