import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';
import '../models/offer.dart';
import '../theme/app_theme.dart';
import '../widgets/offer_card.dart';
import '../widgets/validation_status_widget.dart';
import '../widgets/offer_stats_cards.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OfferProvider>(
        builder: (context, offerProvider, child) {
          if (offerProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return CustomScrollView(
            slivers: [
              // Header avec statistiques
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
                                  'Mes Offres - Tunisie',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Gérez vos offres et suivez leurs performances',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _simulateNewOffer(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Simuler offre'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Cartes de statistiques
                      OfferStatsCards(offerProvider: offerProvider),
                      
                      const SizedBox(height: 20),
                      
                      // Alertes de validation
                      ValidationStatusWidget(offers: offerProvider.offers),
                    ],
                  ),
                ),
              ),
              
              // Barre de recherche et filtres
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Barre de recherche
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Rechercher une offre, gouvernorat, ville...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        offerProvider.setSearchTerm('');
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) => offerProvider.setSearchTerm(value),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Filtres par statut
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  'Toutes (${offerProvider.totalOffers})',
                                  null,
                                  offerProvider.filterStatus,
                                  offerProvider.setFilterStatus,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  'Actives (${offerProvider.activeOffers})',
                                  OfferStatus.active,
                                  offerProvider.filterStatus,
                                  offerProvider.setFilterStatus,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  'En validation (${offerProvider.pendingOffers})',
                                  OfferStatus.pendingValidation,
                                  offerProvider.filterStatus,
                                  offerProvider.setFilterStatus,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  'Rejetées (${offerProvider.rejectedOffers})',
                                  OfferStatus.rejected,
                                  offerProvider.filterStatus,
                                  offerProvider.setFilterStatus,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  'Expirées',
                                  OfferStatus.expired,
                                  offerProvider.filterStatus,
                                  offerProvider.setFilterStatus,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  'Brouillons',
                                  OfferStatus.draft,
                                  offerProvider.filterStatus,
                                  offerProvider.setFilterStatus,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Liste des offres
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: offerProvider.filteredOffers.isEmpty
                    ? SliverToBoxAdapter(
                        child: _buildEmptyState(context),
                      )
                    : SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getCrossAxisCount(context),
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final offer = offerProvider.filteredOffers[index];
                            return OfferCard(
                              offer: offer,
                              onTap: () => _showOfferDetails(context, offer),
                              onEdit: () => _editOffer(context, offer),
                              onDelete: () => _deleteOffer(context, offer),
                              onSimulateValidation: (approve) => 
                                  offerProvider.simulateValidation(offer.id, approve),
                              onUpdateViews: () => offerProvider.updateViews(offer.id),
                            );
                          },
                          childCount: offerProvider.filteredOffers.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  Widget _buildFilterChip(
    String label,
    OfferStatus? status,
    OfferStatus? currentFilter,
    Function(OfferStatus?) onChanged,
  ) {
    final isSelected = currentFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onChanged(selected ? status : null),
      backgroundColor: Colors.grey[100],
      selectedColor: SupplierTheme.blueGradientStart.withOpacity(0.2),
      checkmarkColor: SupplierTheme.blueGradientStart,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.search_off,
                size: 40,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucune offre trouvée',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos critères de recherche',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateNewOffer(BuildContext context) {
    // Simuler l'ajout d'une nouvelle offre
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nouvelle offre simulée ajoutée !'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showOfferDetails(BuildContext context, Offer offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(offer.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Catégorie: ${offer.category}'),
              const SizedBox(height: 8),
              Text('Localisation: ${offer.location}, ${offer.region}'),
              const SizedBox(height: 8),
              Text('Prix: ${offer.promotionalPrice} DT (au lieu de ${offer.originalPrice} DT)'),
              const SizedBox(height: 8),
              Text('Statut: ${offer.status.displayName}'),
              const SizedBox(height: 8),
              Text('Vues: ${offer.views}'),
              const SizedBox(height: 8),
              Text('Réservations: ${offer.bookings}'),
              if (offer.rejectionReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Raison du rejet:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(offer.rejectionReason!),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _editOffer(BuildContext context, Offer offer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Édition de "${offer.title}"'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _deleteOffer(BuildContext context, Offer offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'offre "${offer.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<OfferProvider>().deleteOffer(offer.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Offre supprimée avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
