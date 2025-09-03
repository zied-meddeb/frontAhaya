import 'package:flutter/material.dart';
import 'package:shop/route/screen_export.dart';

import '../../../models/product_model.dart';
import '../../../route/route_constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/favoris_service.dart';
import '../../../services/produit_service.dart';
import '../../../services/categorie_service.dart';
import '../../favoris/views/login_pop_up.dart';
import 'all_product_card.dart';
import 'drawer.dart';

class ProductListingScreen extends StatefulWidget {
  final String? initialSearchTerm;
  
  const ProductListingScreen({super.key, this.initialSearchTerm});

  @override
  _ProductListingScreenState createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String searchTerm = '';
  bool isGridView = true;
  String sortBy = 'popularite';
  int currentPage = 1;
  Set<int> favorites = {};
  final int itemsPerPage = 12;
  List<String> searchSuggestions = [];
  bool showSuggestions = false;
  FocusNode searchFocusNode = FocusNode();

  final ProductService _productService = ProductService();
  final AuthService _auth = AuthService();
  final FavoritesService _favoritesService = FavoritesService();
  final CategoriesService _categoriesService = CategoriesService();

  List<dynamic> productsList = [];
  List<dynamic> allProductsList = []; // Keep original list for filtering
  List<String> favoriteProductIds = [];
  List<dynamic> categories = [];
  List<String> selectedCategoryIds = [];
  bool isLoading = true;
  bool isLoggedIn = false;

  List<dynamic> get filteredProducts {
    List<dynamic> filtered = allProductsList.where((product) {
      // Filter by search term
      if (searchTerm.isNotEmpty) {
        final searchLower = searchTerm.toLowerCase();
        if (!(product.title.toLowerCase().contains(searchLower) ||
              product.brandName.toLowerCase().contains(searchLower) ||
              product.description.toLowerCase().contains(searchLower))) {
          return false;
        }
      }

      // Filter by selected categories (if any categories are selected)
      if (selectedCategoryIds.isNotEmpty) {
        if (product.categoryId == null || !selectedCategoryIds.contains(product.categoryId)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    switch (sortBy) {
      case 'price_low_high':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high_low':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'discount':
        filtered.sort((a, b) => b.dicountpercent.compareTo(a.dicountpercent));
        break;
      case 'name_az':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'name_za':
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'popularite':
      default:
        // Keep original order for popularity (assuming API returns popular items first)
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

    final queryLower = query.toLowerCase();
    final suggestions = allProductsList
        .map((product) => product.title)
        .where((name) => name.toLowerCase().contains(queryLower))
        .toSet()
        .toList();

    setState(() {
      searchSuggestions = suggestions.take(5).toList().cast<String>();
      showSuggestions = suggestions.isNotEmpty;
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  List<dynamic> get paginatedProducts {
    final filtered = filteredProducts;
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get totalPages {
    return (filteredProducts.length / itemsPerPage).ceil();
  }

  void clearFilters() {
    setState(() {
      searchTerm = '';
      selectedCategoryIds.clear();
      // Reset all categories to unchecked if needed
      for (var category in categories) {
        if (category is Map && category.containsKey('checked')) {
          category['checked'] = false;
        }
      }
      currentPage = 1;
      searchSuggestions = [];
      showSuggestions = false;
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 900) return 3;
    return 2;
  }

  Future<void> fetchData() async {
    try {
      final response = await _productService.getAllProducts();

      if (response['data'] != null && response['data'] is List) {
        final products = response['data'].map((item) => ProductModel(
          id: item['_id'] ?? '',
          image: item['imageUrl'] ?? '',
          brandName: item['fournisseur']?['nom'] ?? 'Unknown Brand',
          title: item['nom'] ?? '',
          price: (item['prix'] ?? 0.0).toDouble(),
          priceAfetDiscount: (item['old_prix'] ?? item['prix'] ?? 0.0).toDouble(),
          dicountpercent: item['promotion']?['pourcentage'] ?? 0,
          description: item['description'] ?? '',
          categoryId: item['category']?['_id'] ?? item['category'] ?? '',
          categoryName: item['category']?['nom'] ?? 'Unknown Category',
        )).toList();
        
        setState(() {
          productsList = products;
          allProductsList = products; // Keep original list for filtering
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadInitialData() async {
    try {
      isLoggedIn = await _auth.isLoggedIn();
      await fetchData();
      // Fetch categories after products are loaded to get accurate counts
      await _fetchCategories();
      if (isLoggedIn) {
        await _fetchFavorites();
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categoriesResponse = await _categoriesService.fetchCategories();
      setState(() {
        categories = categoriesResponse.map((item) => {
          'id': item['_id'] ?? '',
          'name': item['nom'] ?? '',
          'checked': false,
          'count': _getProductCountForCategory(item['_id'] ?? ''),
        }).toList();
      });
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  int _getProductCountForCategory(String categoryId) {
    if (allProductsList.isEmpty) return 0;
    return allProductsList.where((product) => product.categoryId == categoryId).length;
  }

  Future<void> _fetchFavorites() async {
    try {
      final userId = await _auth.getUserId();
      if (userId != null && userId.isNotEmpty) {
        final favorites = await _favoritesService.fetchFavorites(userId);
        if (mounted) {
          setState(() {
            favoriteProductIds = favorites.map((product) => product.id).where((id) => id.isNotEmpty).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des favoris: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  bool _isProductFavorite(String productId) {
    return favoriteProductIds.contains(productId);
  }

  Future<void> toggleFavorite(String productId) async {
    if (!mounted) return;
    try {
      final userId = await _auth.getUserId();
      if (userId == null) return;
      
      final isFavorite = _isProductFavorite(productId);
      
      if (isFavorite) {
        // Remove from favorites
        await _favoritesService.removeFavorite(userId, productId);
        setState(() {
          favoriteProductIds.remove(productId);
        });
      } else {
        // Add to favorites
        await _favoritesService.addFavorite(userId, productId);
        setState(() {
          favoriteProductIds.add(productId);
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFavorite ? 'Retiré des favoris' : 'Ajouté aux favoris'),
              backgroundColor: isFavorite ? Colors.orange : Colors.green,
              duration: Duration(seconds: 2),
            ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error occurred: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onCategoryChanged(String categoryId, bool checked) {
    setState(() {
      // Update the category in the categories list
      for (var category in categories) {
        if (category['id'] == categoryId) {
          category['checked'] = checked;
          break;
        }
      }
      
      // Update selected category IDs
      if (checked) {
        selectedCategoryIds.add(categoryId);
      } else {
        selectedCategoryIds.remove(categoryId);
      }
      
      currentPage = 1; // Reset to first page when filter changes
    });
  }

  void _showDiscountModal() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => DiscountModal(),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize search term if provided
    if (widget.initialSearchTerm != null) {
      searchTerm = widget.initialSearchTerm!;
    }
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Text(
              '${filteredProducts.length} résultats',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Spacer(),
            DropdownButton<String>(
              value: sortBy,
              onChanged: (value) {
                setState(() {
                  sortBy = value!;
                  currentPage = 1;
                });
              },
              items: const [
                DropdownMenuItem(value: 'popularite', child: Text('Popularité')),
                DropdownMenuItem(value: 'price_low_high', child: Text('Prix ↑')),
                DropdownMenuItem(value: 'price_high_low', child: Text('Prix ↓')),
                DropdownMenuItem(value: 'name_az', child: Text('A-Z')),
                DropdownMenuItem(value: 'name_za', child: Text('Z-A')),
                DropdownMenuItem(value: 'discount', child: Text('Remise')),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => setState(() => isGridView = true),
                    icon: const Icon(Icons.grid_view),
                    color: isGridView ? Colors.blue : Colors.grey,
                    iconSize: 20,
                  ),
                  IconButton(
                    onPressed: () => setState(() => isGridView = false),
                    icon: const Icon(Icons.list),
                    color: !isGridView ? Colors.blue : Colors.grey,
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: FilterDrawer(
        searchTerm: searchTerm,
        onSearchChanged: (value) {
          setState(() {
            searchTerm = value;
            currentPage = 1;
          });
          _updateSuggestions(value);
        },
        categories: categories,
        onCategoryChanged: _onCategoryChanged,
        onClearFilters: clearFilters,
        searchSuggestions: searchSuggestions,
        onSuggestionSelected: (suggestion) {
          setState(() {
            searchTerm = suggestion;
            showSuggestions = false;
          });
        },
        searchFocusNode: searchFocusNode,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (paginatedProducts.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Aucun produit trouvé',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: clearFilters,
                          child: const Text('Effacer les filtres')),
                    ],
                  ),
                ),
              )
            else ...[
              Expanded(
                child: isGridView
                    ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: paginatedProducts.length,
                  itemBuilder: (context, index) {
                    final product = paginatedProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          productDetailsScreenRoute,
                          arguments: product,
                        ).then((_) {
                          _loadInitialData();
                        });
                      },
                      child: CompactProductCard(
                        product: product,
                        isFavorite: isLoggedIn
                            ? _isProductFavorite(product.id)
                            : false,
                        onToggleFavorite: () async {
                          final productId = product.id;
                          if (isLoggedIn) {
                            await toggleFavorite(productId);
                          } else {
                            _showDiscountModal();
                          }
                        },
                        isListView: false,
                      ),
                    );
                  },
                )
                    : ListView.builder(
                  itemCount: paginatedProducts.length,
                  itemBuilder: (context, index) {
                    final product = paginatedProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          productDetailsScreenRoute,
                          arguments: product,
                        ).then((_) {
                          _loadInitialData();
                        });
                      },
                      child: CompactProductCard(
                        product: product,
                        isFavorite: isLoggedIn
                            ? _isProductFavorite(product.id)
                            : false,
                        onToggleFavorite: () async {
                          final productId = product.id;
                          if (isLoggedIn) {
                            await toggleFavorite(productId);
                          } else {
                            _showDiscountModal();
                          }
                        },
                        isListView: true,
                      ),
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
                        onPressed: currentPage > 1
                            ? () => setState(() => currentPage--)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        '$currentPage / $totalPages',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      IconButton(
                        onPressed: currentPage < totalPages
                            ? () => setState(() => currentPage++)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
