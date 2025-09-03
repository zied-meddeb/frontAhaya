import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../models/promotion.dart'; // Updated to use Promotion model
import '../../services/auth_service.dart';
import '../../services/promotion_service.dart';
import 'modify_offer_screen.dart'; // Import the new ModifyOfferScreen

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PromotionService _promotionService = PromotionService();
  final AuthService _authService = AuthService();
  List<Promotion> _promotions = [];
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchPromotionsByFournisseurId();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPromotionsByFournisseurId() async {
    try {
      final fournisseurId = await _authService.getUserId();
      if (fournisseurId != null) {
        final promotions = await _promotionService.fetchPromotionsByFournisseurId(fournisseurId);
        setState(() {
          _promotions = promotions.map((p) => Promotion.fromJson(p)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des promotions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une promotion...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                              : null,
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        hint: const Text('Filtrer par statut'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tous les statuts'),
                          ),
                          ...['ATT_VER', 'REJETE', 'VALIDE', 'ACTIVE'].map((status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          )),
                        ],
                        onChanged: (value) {
                          if (value != _selectedStatus) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: _filteredPromotions.isEmpty
                ? SliverToBoxAdapter(
              child: _buildEmptyState(context),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final promotion = _filteredPromotions[index];
                  return _buildPromotionCard(context, promotion);
                },
                childCount: _filteredPromotions.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Promotion> get _filteredPromotions {
    final query = _searchController.text.toLowerCase();
    return _promotions.where((promotion) {
      final matchesSearch =
          promotion.titre.toLowerCase().contains(query);
      final matchesStatus = _selectedStatus == null || promotion.statut == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Widget _buildPromotionCard(BuildContext context, Promotion promotion) {
    final statusColors = {
      'ATT_VER': Colors.blue,
      'REJETE': Colors.red,
      'VALIDE': Colors.green[800],
      'ACTIVE': Colors.green[300],
    };

    return GestureDetector(
      onTap: () async {
        final updatedPromotion = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModifyOfferScreen(promotionId: promotion.id),
          ),
        );

        if (updatedPromotion != null && updatedPromotion is Promotion) {
          // Update the promotion in the list
          setState(() {
            final index = _promotions.indexWhere((p) => p.id == updatedPromotion.id);
            if (index != -1) {
              _promotions[index] = updatedPromotion;
            }
          });
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  promotion.afficheUrls.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      promotion.afficheUrls.first,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  )
                      : Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promotion.titre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Prix original: ${promotion.prixOriginal.toStringAsFixed(2)} DT',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Prix offre: ${promotion.prixOffre.toStringAsFixed(2)} DT',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Du: ${DateFormat('dd/MM/yyyy').format(promotion.dateDebut)} au ${DateFormat('dd/MM/yyyy').format(promotion.dateFin)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (promotion.statut != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColors[promotion.statut] ?? Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      promotion.statut!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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
              'Aucune promotion trouvée',
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
}
