import 'package:flutter/material.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/services/user_service.dart';

import '../../../models/category_model.dart';
import '../../../services/categorie_service.dart';

class CategoriesSelectionPage extends StatefulWidget {
  const CategoriesSelectionPage({Key? key}) : super(key: key);

  @override
  State<CategoriesSelectionPage> createState() => _CategoriesSelectionPageState();
}

class _CategoriesSelectionPageState extends State<CategoriesSelectionPage> {
  List<dynamic> categories = [];
  bool isLoading = true;

  final CategoriesService _categoriesService = CategoriesService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  void toggleCategory(String id) {
    setState(() {
      final category = categories.firstWhere((cat) => cat.id == id);
      category.selected = !category.selected;
    });
  }

  Future<void> handleConfirm() async {
    try {
      final selectedCategories = categories.where((cat) => cat.selected).toList();
      debugPrint("Selected categories: ${selectedCategories.map((c) => c.id).toList()}");

      final userId =await _authService.getUserId();
      print("userid $userId");
      await _userService.updateUserPreferences(userId, selectedCategories);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferences updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      debugPrint('Unexpected error: $e');
    }
  }



  Future<void> fetchUserCategories() async {
    try {
      final userId = await _authService.getUserId();
      final response = await _userService.getUserPreferences(userId);
      print('reponse $response');

      final userCategoryIds = List<String>.from(response ?? []);


      setState(() {
        for (var category in categories) {
          if (userCategoryIds.contains(category.id)) {
            category.selected = true;
          }
        }
        isLoading = false;
      });
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Error fetching user categories: $e');
      setState(() => isLoading = false);
      // Optionally, show a generic error message to the user
    }
  }



  Future<void> fetchCategories() async {
    try {
      final response = await _categoriesService.fetchCategories();
      print("categories $response");
      setState(() {
        categories = response.map((item) => Category(
          name: item['nom'] ?? '',
          icon: item['icon'],
          id: item['_id'] ?? '',
        )).toList();
        isLoading = false;
        fetchUserCategories();
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 24, top: 32, bottom: 16), // Adjusted padding
              child: Row( // Changed to Row for horizontal alignment
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to start and end
                children: [
                  IconButton( // Added IconButton for back navigation
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded( // Wrap Column in Expanded to allow it to take available space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // Center text horizontally
                      children: [
                        const Text(
                          'CATÉGORIES',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Éditer mes centres d\'intérêt.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Placeholder to balance the IconButton on the left
                ],
              ),
            ),


            const SizedBox(height: 20),

            // Categories Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () => toggleCategory(category.id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: category.selected
                              ? Colors.black.withOpacity(0.05)
                              : Colors.grey[100],
                          border: Border.all(
                            color: category.selected
                                ? Colors.black
                                : Colors.grey[200]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: category.selected
                              ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    IconData(
                                      category.icon,
                                      fontFamily: 'MaterialIcons',
                                    ),
                                    size: 32,
                                    color: category.selected
                                        ? Colors.black
                                        : Colors.grey[700],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: category.selected
                                          ? Colors.black
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Selection indicator
                            if (category.selected)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.circle,
                                      color: Colors.white,
                                      size: 8,
                                    ),
                                  ),
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

            // Confirm Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'CONFIRMER',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
