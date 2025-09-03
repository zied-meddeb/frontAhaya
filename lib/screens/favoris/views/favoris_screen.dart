
import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';

import 'package:shop/route/route_constants.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/favoris_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> with RouteAware {
  List<dynamic> products = [];
  bool isLoading = true;
  bool isLoggedIn = false;

  final AuthService _auth = AuthService();
  final FavoritesService _favoritesService = FavoritesService();

  // Get the RouteObserver from a global provider or ancestor
  // For simplicity, assuming it's available via a static getter or passed down.
  // In a real app, use Provider or InheritedWidget to get the RouteObserver.
  final RouteObserver<ModalRoute<void>> _routeObserver = RouteObserver<ModalRoute<void>>();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    // Make sure you have a RouteObserver in your MaterialApp
    // final routeObserver = ModalRoute.of(context)?.navigator?.widget.observers.firstWhere((observer) => observer is RouteObserver<ModalRoute<void>>) as RouteObserver<ModalRoute<void>>?;
    // For now, using a local one, but ideally it should be shared.
    _routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      isLoggedIn = await _auth.isLoggedIn();
      if (isLoggedIn) {
        final user = await _auth.getUserId();
        await _fetchFavorites(user!);
      } else {
        if (mounted) {
          setState(() => products = []); // Clear products if not logged in
        }
      }
      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      print('Error checking auth status: $e');
    }
  }

  Future<void> _fetchFavorites(String userId) async {
    try {
      final favorites = await _favoritesService.fetchFavorites(userId);
      // Check if the widget is still in the tree before calling setState
      if (mounted) {
        setState(() {
          products = favorites;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      print('$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
        ),
      );

    }
  }

  // Called when the current route has been popped off.
  @override
  void didPopNext() {
    // Screen is coming back into view
    if (mounted) {
       _checkAuthStatus(); // Refresh favorites
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          if (isLoading)

            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200.0,
                  mainAxisSpacing: defaultPadding,
                  crossAxisSpacing: defaultPadding,
                  childAspectRatio: 0.66,
                ),
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return ProductCard(
                      id: products[index].id,
                      image: products[index].image,
                      brandName: products[index].brandName,
                      title: products[index].title,
                      price: products[index].price,
                      priceAfetDiscount: products[index].priceAfetDiscount,
                      dicountpercent: products[index].dicountpercent,
                      isFavorite: true,
                      press: () {
                        Navigator.pushNamed( // Make sure this navigation is handled in a way that allows the screen to refresh on return
                          context,
                          productDetailsScreenRoute,
                          arguments: products[index], // Pass the product as argument
                        ).then((_) {
                          // This block executes when the pushed screen is popped.
                          // Refresh the favorites list.
                           _checkAuthStatus();
                        });
                      },
                      onFavoritePressed: () async {
                        // Ensure the widget is still mounted before calling setState
                        if (mounted) {
                          setState(() {
                            products.removeAt(index);
                          });
                        }
                      },
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
