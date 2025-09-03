import 'package:flutter/material.dart';

class Transaction {
  final int id;
  final DateTime date;
  final String description;
  final String customer;
  final double amount;
  final double commission;
  final double net;
  final TransactionStatus status;
  final TransactionType type;
  final int offerId;

  Transaction({
    required this.id,
    required this.date,
    required this.description,
    required this.customer,
    required this.amount,
    required this.commission,
    required this.net,
    required this.status,
    required this.type,
    required this.offerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'customer': customer,
      'amount': amount,
      'commission': commission,
      'net': net,
      'status': status.name,
      'type': type.name,
      'offerId': offerId,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      customer: json['customer'],
      amount: json['amount'].toDouble(),
      commission: json['commission'].toDouble(),
      net: json['net'].toDouble(),
      status:
          TransactionStatus.values.firstWhere((e) => e.name == json['status']),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      offerId: json['offerId'],
    );
  }
}

enum TransactionStatus {
  paid,
  pending,
  processed,
  failed,
}

enum TransactionType {
  booking,
  refund,
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.paid:
        return 'Payé';
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.processed:
        return 'Traité';
      case TransactionStatus.failed:
        return 'Échoué';
    }
  }

  Color get color {
    switch (this) {
      case TransactionStatus.paid:
        return const Color(0xFF000000);
      case TransactionStatus.pending:
        return const Color(0xFF424242);
      case TransactionStatus.processed:
        return const Color(0xFF000000);
      case TransactionStatus.failed:
        return const Color(0xFF757575);
    }
  }
}
