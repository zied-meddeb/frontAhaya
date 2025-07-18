import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;

  bool get isLoading => _isLoading;

  // Statistiques mensuelles
  double get monthlyRevenue {
    final now = DateTime.now();
    final currentMonthTransactions = _transactions
        .where((t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.amount > 0)
        .toList();

    return currentMonthTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyCommissions {
    final now = DateTime.now();
    final currentMonthTransactions = _transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();

    return currentMonthTransactions.fold(0.0, (sum, t) => sum + t.commission);
  }

  double get monthlyNet {
    final now = DateTime.now();
    final currentMonthTransactions = _transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();

    return currentMonthTransactions.fold(0.0, (sum, t) => sum + t.net);
  }

  double get pendingAmount {
    return _transactions
        .where((t) => t.status == TransactionStatus.pending)
        .fold(0.0, (sum, t) => sum + t.net);
  }

  TransactionProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await loadTransactions();
    if (_transactions.isEmpty) {
      await _createSampleData();
    }
  }

  Future<void> _createSampleData() async {
    final tunisianNames = [
      'Amira Ben Salem',
      'Mohamed Trabelsi',
      'Leila Khelifi',
      'Youssef Hamdi',
      'Fatma Bouazizi',
      'Ahmed Nasri',
    ];

    final sampleTransactions = [
      Transaction(
        id: 1,
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Restaurant Dar Zarrouk - Réservation #1234',
        customer: tunisianNames[0],
        amount: 32.0,
        commission: 3.2,
        net: 28.8,
        status: TransactionStatus.paid,
        type: TransactionType.booking,
        offerId: 1,
      ),
      Transaction(
        id: 2,
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Spa Thalasso Sousse - Réservation #1233',
        customer: tunisianNames[1],
        amount: 55.0,
        commission: 5.5,
        net: 49.5,
        status: TransactionStatus.paid,
        type: TransactionType.booking,
        offerId: 2,
      ),
      Transaction(
        id: 3,
        date: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Hôtel Villa Didon - Réservation #1232',
        customer: tunisianNames[2],
        amount: 135.0,
        commission: 13.5,
        net: 121.5,
        status: TransactionStatus.pending,
        type: TransactionType.booking,
        offerId: 3,
      ),
      Transaction(
        id: 4,
        date: DateTime.now().subtract(const Duration(days: 4)),
        description: 'Remboursement - Annulation #1230',
        customer: tunisianNames[3],
        amount: -25.0,
        commission: 2.5,
        net: -27.5,
        status: TransactionStatus.processed,
        type: TransactionType.refund,
        offerId: 4,
      ),
    ];

    _transactions = sampleTransactions;
    await saveTransactions();
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getString('supplier_transactions');

      if (transactionsJson != null) {
        final List<dynamic> transactionsList = json.decode(transactionsJson);
        _transactions =
            transactionsList.map((json) => Transaction.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des transactions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson =
          json.encode(_transactions.map((t) => t.toJson()).toList());
      await prefs.setString('supplier_transactions', transactionsJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des transactions: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.insert(0, transaction);
    await saveTransactions();
    notifyListeners();
  }

  Future<void> simulateNewTransaction() async {
    final tunisianNames = [
      'Amira Ben Salem',
      'Mohamed Trabelsi',
      'Leila Khelifi',
      'Youssef Hamdi',
      'Fatma Bouazizi',
      'Ahmed Nasri',
    ];

    final random = Random();
    final randomName = tunisianNames[random.nextInt(tunisianNames.length)];
    final amount = 25.0 + random.nextDouble() * 100; // 25-125 DT
    final commission = amount * 0.1;
    final net = amount - commission;

    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch,
      date: DateTime.now(),
      description: 'Nouvelle réservation #${random.nextInt(9999)}',
      customer: randomName,
      amount: amount,
      commission: commission,
      net: net,
      status: TransactionStatus.pending,
      type: TransactionType.booking,
      offerId: 1,
    );

    await addTransaction(newTransaction);
  }
}
