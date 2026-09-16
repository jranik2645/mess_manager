import 'package:cloud_firestore/cloud_firestore.dart';

class DepositModel {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final DateTime date;
  final String monthKey;
  final String paymentMethod;
  final String note;
  final DateTime createdAt;

  DepositModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.date,
    required this.monthKey,
    this.paymentMethod = 'Cash (নগদ)',
    this.note = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  DepositModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    double? amount,
    DateTime? date,
    String? monthKey,
    String? paymentMethod,
    String? note,
    DateTime? createdAt,
  }) {
    return DepositModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      monthKey: monthKey ?? this.monthKey,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'monthKey': monthKey,
      'paymentMethod': paymentMethod,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory DepositModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return DepositModel(
      id: docId ?? map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: parseDate(map['date']),
      monthKey: map['monthKey'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'Cash (নগদ)',
      note: map['note'] ?? '',
      createdAt: parseDate(map['createdAt']),
    );
  }
}

