import 'package:flutter/material.dart';
import 'package:shop/screens/discover/views/product.dart';
import '../../../models/product_model.dart';
import '../../../route/route_constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/favoris_service.dart';
import '../../../services/produit_service.dart';
import '../../favoris/views/login_pop_up.dart';
import 'all_product_card.dart';
import 'drawer.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  _ProductListingScreenState createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String searchTerm = '';
  bool isGridView = true;
  String sortBy = 'popularite';
  List<Category> categories = ProductsData.categories;
  int currentPage = 1;
  Set<int> favorites = {};
  final int itemsPerPage = 12;
  List<String> searchSuggestions = [];
  bool showSuggestions = false;
  FocusNode searchFocusNode = FocusNode();

  List<dynamic> get filteredProducts {
    List<dynamic> filtered = productsList.where((product) {
      if (searchTerm.isNotEmpty) {
        final productName = product.title.toLowerCase();
        final searchLower = searchTerm.toLowerCase();
        if (!productName.contains(searchLower)) {
          return false;
        }
      }

      // List<String> selectedCategories = categories
      //     .where((cat) => cat.checked)
      //     .map((cat) => cat.name)
      //     .toList();
      // if (selectedCategories.isNotEmpty &&
      //     !selectedCategories.contains(product.category)) {
      //   return false;
      // }

      return true;
    }).toList();

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
    final suggestions = productsList
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
      categories = categories.map((cat) => Category(name: cat.name, count: cat.count)).toList();
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

  final ProductService _productService = ProductService();
  final AuthService _auth = AuthService();
  final FavoritesService _favoritesService = FavoritesService();

  List<dynamic> productsList = [];
  List<String> favoriteProductIds = [];
  bool isLoading = true;
  bool isLoggedIn = false;

  Future<void> fetchData() async {
    try {
      final response = await _productService.getAllProducts();

      setState(() {
        productsList = response['data'].map((item) => ProductModel(
          id: item['_id'] ?? '',
          image: item['imageUrl'] ?? '',
          brandName: item['fournisseur']['nom'] ?? 'Unknown Brand',
          title: item['nom'] ?? '',
          price: item['prix'].toDouble() ?? 0.0,
          priceAfetDiscount: item['old_prix']?.toDouble() ?? item['prix'].toDouble(),
          dicountpercent: item['promotion']?['pourcentage'] ?? 0,
          description: item['description'] ?? '',
        )).toList();
      });

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

  Future<void> _fetchFavorites() async {
    try {
      final userId = await _auth.getUserId();
      if (userId != null) {
        final favorites = await _favoritesService.fetchFavorites(userId);
        setState(() {
          favoriteProductIds = favorites.map((product) => product.id).toList();
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

  bool _isProductFavorite(String productId) {
    return favoriteProductIds.contains(productId);
  }

  Future<void> addToFavorites(id) async {
    if (!mounted) return;
    try {
      final userId = await _auth.getUserId();
      await _favoritesService.addFavorite(userId as String, id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opération réussie'),
              backgroundColor: Colors.green,
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
              '${productsList.length} résultats',
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
                DropdownMenuItem(value: 'prix-croissant', child: Text('Prix ↑')),
                DropdownMenuItem(value: 'prix-decroissant', child: Text('Prix ↓')),
                DropdownMenuItem(value: 'nouveautes', child: Text('Nouveautés')),
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
        onCategoryChanged: (category, checked) {
          setState(() {
            category.checked = checked;
            currentPage = 1;
          });
        },
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
                            await addToFavorites(productId);
                            if (mounted) {
                              setState(() {
                                if (_isProductFavorite(productId)) {
                                  favoriteProductIds.remove(productId);
                                } else {
                                  favoriteProductIds.add(productId);
                                }
                              });
                            }
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
                            await addToFavorites(productId);
                            if (mounted) {
                              setState(() {
                                if (_isProductFavorite(productId)) {
                                  favoriteProductIds.remove(productId);
                                } else {
                                  favoriteProductIds.add(productId);
                                }
                              });
                            }
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

class ProductsData {
  static List<Product> products = [
    Product(
      id: 1,
      name: "Parfum Élégance",
      price: 89.99,
      originalPrice: 99.99,
      discount: "-10%",
      discountType: "green",
      rating: 4.5,
      reviewCount: 124,
      image: "https://via.placeholder.com/200x200/E8E8E8/666666?text=Parfum",
      category: "Parfums",
      brand: "Luxe Paris",
      description: "Un parfum sophistiqué aux notes florales",
    ),
    // ... other products ...
  ];

  static List<Category> categories = [
    Category(name: "Mode et beauté", count: 143),
    Category(name: "Parfums", count: 89),
    Category(name: "Soin du corps", count: 28),
    Category(name: "Vêtements", count: 156),
    Category(name: "Sous-vêtements", count: 7),
    Category(name: "Chaussures", count: 2),
  ];
}

class Category {
  final String name;
  final int count;
  bool checked;

  Category({
    required this.name,
    required this.count,
    this.checked = false,
  });
}
