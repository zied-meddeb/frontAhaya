import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';


class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          if (transactionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🇹🇳', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Paiements & Facturation - Tunisie',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Suivez vos revenus en dinars tunisiens et gérez vos finances',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => transactionProvider.simulateNewTransaction(),
                            icon: const Icon(Icons.add),
                            label: const Text('Simuler transaction'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Cartes de statistiques
                      _buildStatsCards(transactionProvider),
                    ],
                  ),
                ),
              ),
              
              // Tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: SupplierTheme.mediumGray),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: SupplierTheme.blackGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: SupplierTheme.mediumGray,
                      tabs: const [
                        Tab(text: 'Transactions'),
                        Tab(text: 'Factures'),
                        Tab(text: 'Paramètres'),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransactionsTab(transactionProvider),
                    _buildInvoicesTab(),
                    _buildSettingsTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(TransactionProvider provider) {
    final stats = [
      {
        'title': 'Revenus ce mois',
        'value': '${provider.monthlyRevenue.toStringAsFixed(0)} DT',
        'change': '+18%',
        'icon': Icons.attach_money,
        'gradient': SupplierTheme.grayGradient,
      },
      {
        'title': 'Commissions',
        'value': '${provider.monthlyCommissions.toStringAsFixed(0)} DT',
        'change': '-3%',
        'icon': Icons.account_balance_wallet,
        'gradient': SupplierTheme.blackGradient,
      },
      {
        'title': 'Revenus nets',
        'value': '${provider.monthlyNet.toStringAsFixed(0)} DT',
        'change': '+22%',
        'icon': Icons.trending_up,
        'gradient': SupplierTheme.whiteGradient,
      },
      
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          decoration: BoxDecoration(
            gradient: stat['gradient'] as LinearGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stat['title'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat['value'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if ((stat['change'] as String).isNotEmpty)
                        Text(
                          '${stat['change']} vs mois dernier',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsTab(TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historique des Transactions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Toutes vos transactions et commissions en dinars tunisiens',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _exportTransactions(provider.transactions),
                    icon: const Icon(Icons.download),
                    label: const Text('Exporter CSV'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = provider.transactions[index];
                  return _buildTransactionCard(transaction);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: SupplierTheme.mediumGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: SupplierTheme.grayGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              transaction.amount >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
              color: transaction.amount >= 0 ? SupplierTheme.primaryBlack : SupplierTheme.mediumGray,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _buildStatusBadge(transaction.status),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: SupplierTheme.mediumGray),
                    const SizedBox(width: 4),
                    Text(
                      transaction.customer,
                      style: TextStyle(
                        fontSize: 12,
                        color: SupplierTheme.mediumGray,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 14, color: SupplierTheme.mediumGray),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(transaction.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: SupplierTheme.mediumGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.amount >= 0 ? '+' : ''}${transaction.amount.toStringAsFixed(1)} DT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: transaction.amount >= 0 ? SupplierTheme.primaryBlack : SupplierTheme.mediumGray,
                ),
              ),
              Text(
                'Commission: ${transaction.commission.toStringAsFixed(1)} DT',
                style: TextStyle(
                  fontSize: 12,
                  color: SupplierTheme.mediumGray,
                ),
              ),
              Text(
                'Net: ${transaction.net >= 0 ? '+' : ''}${transaction.net.toStringAsFixed(1)} DT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: transaction.net >= 0 ? SupplierTheme.primaryBlack : SupplierTheme.mediumGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: status.color,
        ),
      ),
    );
  }

  Widget _buildInvoicesTab() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Factures',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Fonctionnalité en cours de développement',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Paramètres de Paiement',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Fonctionnalité en cours de développement',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 2;
    return 1;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _exportTransactions(List<Transaction> transactions) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export CSV simulé - Fonctionnalité en cours de développement'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
