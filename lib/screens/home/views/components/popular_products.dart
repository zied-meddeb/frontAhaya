import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/services/produit_service.dart';
import '../../../../constants.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/favoris_service.dart';
import '../../../discover/views/all_products_screen.dart';
import '../../../favoris/views/login_pop_up.dart';

class PopularProducts extends StatefulWidget {
  const PopularProducts({super.key});

  @override
  State<PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
  List<dynamic> products = [];
  List<String> favoriteProductIds = [];
  bool isLoading = true;
  bool isLoggedIn = false;

  final AuthService _auth = AuthService();
  final FavoritesService _favoritesService = FavoritesService();
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Check login status first
      isLoggedIn = await _auth.isLoggedIn();

      // Fetch products
      await fetchData();

      // If logged in, fetch favorites
      if (isLoggedIn) {
        await _fetchFavorites();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await _productService.getAllProducts();

      if (response['data'] != null && response['data'] is List) {
        setState(() {
          products = response['data'].map((item) => ProductModel(
            id: item['_id'] ?? '',
            image: item['imageUrl'] ?? '',
            brandName: item['fournisseur']?['nom'] ?? 'Unknown Brand',
            title: item['nom'] ?? '',
            price: (item['prix'] ?? 0.0).toDouble(),
            priceAfetDiscount: (item['old_prix'] ?? item['prix'] ?? 0.0).toDouble(),
            dicountpercent: item['promotion']?['pourcentage'] ?? 0,
            description: item['description'] ?? '',
          )).toList();
        });
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
      if (userId == null || userId.isEmpty) return;
      
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
            content: Text("Erreur: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Text(
                "Tous les produits",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductListingScreen(),
                    maintainState: true,
                  ),
                );
              },
              label: const Text(
                "Voir plus",
                style: TextStyle(
                  fontWeight: FontWeight.w500, 
                  color: Colors.black,
                  fontSize: 12
                ),
              ),
              icon: const Icon(
                Icons.arrow_forward,
                size: 12,
                color: Colors.black,
              ),
            ),

          ],
        ),
        SizedBox(
          height: 220,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: defaultPadding,
                right: index == products.length - 1
                    ? defaultPadding
                    : 0,
              ),
              child: ProductCard(
                id: products[index].id,
                image: products[index].image,
                brandName: products[index].brandName,
                title: products[index].title,
                price: products[index].price,
                priceAfetDiscount: products[index].priceAfetDiscount,
                dicountpercent: products[index].dicountpercent,
                isFavorite: isLoggedIn
                    ? _isProductFavorite(products[index].id)
                    : false,
                press: () {
                  Navigator.pushNamed(
                    context,
                    productDetailsScreenRoute,
                    arguments: products[index],
                  );
                },
                onFavoritePressed: () async {
                  final productId = products[index].id;
                  if (isLoggedIn) {
                    await toggleFavorite(productId);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => DiscountModal(),
                    );
                  }
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
