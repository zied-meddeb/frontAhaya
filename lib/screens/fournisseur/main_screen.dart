import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/offer_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';
import 'create_offer_screen.dart';
import 'my_offers_screen.dart';
import 'payments_screen.dart';
import 'catalogue_screen.dart';
import 'profile_screen.dart';


class MainScreen extends StatefulWidget {
  final int? initialTabIndex;
  
  const MainScreen({super.key, this.initialTabIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const CreateOfferScreen(),
    const MyOffersScreen(),
    const CatalogueScreen(),
    const PaymentsScreen(),
    const FournisseurProfileScreen(),
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
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: 'Catalogue',
    ),
    const NavigationDestination(
      icon: Icon(Icons.payment_outlined),
      selectedIcon: Icon(Icons.payment),
      label: 'Paiements',
    ),
    const NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Set initial tab index if provided
    if (widget.initialTabIndex != null) {
      _currentIndex = widget.initialTabIndex!;
    }
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





  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      destinations: _destinations,
      backgroundColor: SupplierTheme.primaryWhite,
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
            backgroundColor: SupplierTheme.lightGray,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Contenu principal
          Expanded(
            child: Column(
              children: [

                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
