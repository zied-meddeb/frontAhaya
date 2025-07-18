import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/search/views/components/search_form.dart';
import '../../../models/product_model.dart';
import '../../../route/route_constants.dart';
import '../../../services/produit_service.dart';
import 'dart:async';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final ProductService _productService = ProductService();
  List<ProductModel> productsList = [];
  List<ProductModel> suggestedProducts = [];
  bool isLoading = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  final GlobalKey _textFieldKey = GlobalKey(); // To get TextFormField position

  Future<void> fetchData(String query) async {
    if (query.isEmpty) {
      setState(() {
        suggestedProducts = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _productService.getProductByCriteria(query);
      print('API Response: ${response['data']}');

      setState(() {
        productsList = response['data'].map<ProductModel>((item) => ProductModel(
          id: item['_id'] ?? '',
          image: item['imageUrl'] ?? '',
          brandName: item['fournisseur']['nom'] ?? 'Unknown Brand',
          title: item['nom'] ?? '',
          price: item['prix'].toDouble() ?? 0.0,
          priceAfetDiscount: item['old_prix']?.toDouble() ?? item['prix'].toDouble(),
          dicountpercent: item['promotion']?['pourcentage'] ?? 0,
          description: item['description'] ?? '',
        )).toList();

        suggestedProducts = productsList.take(5).toList();
        isLoading = false;
      });

      print('Suggested Products: ${suggestedProducts.length}');
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
        suggestedProducts = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Stack(
                clipBehavior: Clip.none, // Allow dropdown to overflow
                children: [
                  TextFormField(
                    key: _textFieldKey,
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                      _debounceTimer?.cancel();
                      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                        if (value.length > 2) {
                          fetchData(value);
                        } else {
                          setState(() {
                            suggestedProducts = [];
                          });
                        }
                      });
                    },
                    onFieldSubmitted: (value) {
                      setState(() {
                        suggestedProducts = [];
                      });
                    },
                  ),
                  if (_focusNode.hasFocus && suggestedProducts.isNotEmpty || isLoading)
                    Positioned(
                      top: 60, // Adjust based on TextFormField height
                      left: 0,
                      right: 0,
                      child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : suggestedProducts.isEmpty
                              ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No suggestions found'),
                          )
                              : ListView.builder(

                            shrinkWrap: true,
                            itemCount: suggestedProducts.length,
                            itemBuilder: (context, index) {
                              final product = suggestedProducts[index];
                              return GestureDetector(
                                onTap: () {
                                  print("trtttt");
                                  Navigator.pushNamed(
                                    context,
                                    productDetailsScreenRoute,
                                    arguments: product,
                                  );
                                },
                                child: ListTile(
                                  leading: product.image.isNotEmpty
                                      ? Image.network(
                                    product.image,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                                  )
                                      : const Icon(Icons.image),
                                  title: Text(product.title),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        '${product.price.toStringAsFixed(2)} DT',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4), // Increased from 4 to 6
                                      Text(
                                        '${product.priceAfetDiscount!.toStringAsFixed(2)} DT',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
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
