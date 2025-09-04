import 'package:flutter/material.dart';
import '../../../models/promotion.dart';
import '../../../route/route_constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/favoris_service.dart';
import '../../../services/promotion_service.dart';
import '../../../services/categorie_service.dart';
import '../../favoris/views/login_pop_up.dart';
import 'promotionCard.dart';
import 'drawer.dart';

class PromotionListingScreen extends StatefulWidget {
  final String? initialSearchTerm;

  const PromotionListingScreen({Key? key, this.initialSearchTerm}) : super(key: key);

  @override
  _PromotionListingScreenState createState() => _PromotionListingScreenState();
}

class _PromotionListingScreenState extends State<PromotionListingScreen> {
  String searchTerm = '';
  bool isGridView = true;
  String sortBy = 'date_debut';
  int currentPage = 1;
  final int itemsPerPage = 12;
  List<String> searchSuggestions = [];
  bool showSuggestions = false;
  FocusNode searchFocusNode = FocusNode();

  final PromotionService _promoService = PromotionService();
  final AuthService _auth = AuthService();
  final FavoritesService _favoritesService = FavoritesService();
  final CategoriesService _categoriesService = CategoriesService();

  List<Promotion> allPromotions = [];
  List<Promotion> promotionsList = [];
  List<String> favoriteIds = [];
  List<dynamic> categories = [];
  List<String> selectedCategoryIds = [];
  bool isLoading = true;
  bool isLoggedIn = false;

  List<Promotion> get filteredPromotions {
    final lower = searchTerm.toLowerCase();
    var filtered = allPromotions.where((p) {
      if (searchTerm.isNotEmpty &&
          !p.titre.toLowerCase().contains(lower) &&
          !p.description.toLowerCase().contains(lower) &&
          !p.type.toLowerCase().contains(lower)) {
        return false;
      }
      return true;
    }).toList();

    switch (sortBy) {
      case 'prix_asc':
        filtered.sort((a, b) => a.prixOffre.compareTo(b.prixOffre));
        break;
      case 'prix_desc':
        filtered.sort((a, b) => b.prixOffre.compareTo(a.prixOffre));
        break;
      case 'date_fin':
        filtered.sort((a, b) => a.dateFin.compareTo(b.dateFin));
        break;
      case 'date_debut':
      default:
        filtered.sort((a, b) => a.dateDebut.compareTo(b.dateDebut));
        break;
    }

    return filtered;
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        searchSuggestions = [];
        showSuggestions = false;
      });
      return;
    }
    final lower = query.toLowerCase();
    final suggestions = allPromotions
        .map((p) => p.titre)
        .where((t) => t.toLowerCase().contains(lower))
        .toSet()
        .toList();
    setState(() {
      searchSuggestions = suggestions.take(5).toList();
      showSuggestions = suggestions.isNotEmpty;
    });
  }

  List<Promotion> get paginatedPromotions {
    final filtered = filteredPromotions;
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int get totalPages => (filteredPromotions.length / itemsPerPage).ceil();

  void clearFilters() {
    setState(() {
      searchTerm = '';
      selectedCategoryIds.clear();
      currentPage = 1;
      searchSuggestions = [];
      showSuggestions = false;
    });
  }

  Future<void> _loadData() async {
    isLoggedIn = await _auth.isLoggedIn();
    try {
      final promos = await _promoService.fetchAllPromotions();
      promotionsList = promos;
      allPromotions = promos;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchTerm != null) {
      searchTerm = widget.initialSearchTerm!;
    }
    _loadData();
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 900) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Text('${filteredPromotions.length} résultats', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            Spacer(),
            DropdownButton<String>(
              value: sortBy,
              onChanged: (v) => setState(() { sortBy = v!; currentPage = 1; }),
              items: const [
                DropdownMenuItem(value: 'date_debut', child: Text('Début ↑')),
                DropdownMenuItem(value: 'date_fin', child: Text('Fin ↑')),
                DropdownMenuItem(value: 'prix_asc', child: Text('Prix ↑')),
                DropdownMenuItem(value: 'prix_desc', child: Text('Prix ↓')),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => setState(() => isGridView = true),
                    icon: Icon(Icons.grid_view), color: isGridView ? Colors.blue : Colors.grey,
                  ),
                  IconButton(
                    onPressed: () => setState(() => isGridView = false),
                    icon: Icon(Icons.list), color: !isGridView ? Colors.blue : Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: FilterDrawer(
        searchTerm: searchTerm,
        onSearchChanged: (v) { setState(() { searchTerm = v; currentPage = 1; }); _updateSuggestions(v); },
        categories: categories,
        onCategoryChanged: (_, __) {},
        onClearFilters: clearFilters,
        searchSuggestions: searchSuggestions,
        onSuggestionSelected: (s) { setState(() { searchTerm = s; showSuggestions = false; }); },
        searchFocusNode: searchFocusNode,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: isGridView
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getCrossAxisCount(context),
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: paginatedPromotions.length,
                      itemBuilder: (ctx, i) {
                        final promo = paginatedPromotions[i];
                        print(promo.toString());
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, promotionDetailsRoute, arguments: promo),
                          child: PromotionCard(promotion: promo),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: paginatedPromotions.length,
                      itemBuilder: (ctx, i) {
                        final promo = paginatedPromotions[i];
                        print(promo.toString());
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, promotionDetailsRoute, arguments: promo),
                          child: PromotionCard(promotion: promo, isListView: true),
                        );
                      },
                    ),
            ),
            if (totalPages > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left),
                      onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null,
                    ),
                    Text('$currentPage / $totalPages'),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
