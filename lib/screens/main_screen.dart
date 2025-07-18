import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import 'create_offer_screen.dart';
import 'my_offers_screen.dart';
import 'payments_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const CreateOfferScreen(),
    const MyOffersScreen(),
    const PaymentsScreen(),
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.add_business),
      selectedIcon: Icon(Icons.add_business),
      label: 'Créer Offre',
    ),
    const NavigationDestination(
      icon: Icon(Icons.business_center_outlined),
      selectedIcon: Icon(Icons.business_center),
      label: 'Mes Offres',
    ),
    const NavigationDestination(
      icon: Icon(Icons.payment_outlined),
      selectedIcon: Icon(Icons.payment),
      label: 'Paiements',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfferProvider>().loadOffers();
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    if (isWideScreen) {
      return _buildWideScreenLayout();
    }

    return Scaffold(
      body: Column(
        children: [
          // Header personnalisé
          _buildHeader(context),
          // Contenu principal
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      // Navigation pour écrans étroits
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: const Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Drapeau et titre
              const Text('🇹🇳', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => SupplierTheme.blueGradient.createShader(bounds),
                      child: const Text(
                        'Espace Fournisseur Tunisie',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'Gérez vos offres et paiements',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Navigation pour écrans larges
              if (MediaQuery.of(context).size.width > 800) _buildTabNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _destinations.asMap().entries.map((entry) {
          final index = entry.key;
          final destination = entry.value;
          final isSelected = _currentIndex == index;
          
          return GestureDetector(
            onTap: () => setState(() => _currentIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Text(
                destination.label,
                style: TextStyle(
                  color: isSelected ? SupplierTheme.blueGradientStart : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      destinations: _destinations,
      backgroundColor: Colors.white,
      elevation: 8,
    );
  }

  Widget _buildWideScreenLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Navigation rail
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            labelType: NavigationRailLabelType.all,
            destinations: _destinations.map((dest) => NavigationRailDestination(
              icon: dest.icon,
              selectedIcon: dest.selectedIcon,
              label: Text(dest.label),
            )).toList(),
            backgroundColor: Colors.grey[50],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Contenu principal
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
