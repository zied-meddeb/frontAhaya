import 'package:shop/models/product_model.dart';
import 'package:dio/dio.dart';

import 'auth_service.dart';
import 'dio_interceptor.dart';

class FavoritesService {
  final String baseUrl;
  late final Dio dio;
  final AuthService _auth = AuthService();

  // Constructor with optional baseUrl parameter for flexibility
  FavoritesService({this.baseUrl = 'http://localhost:3100/api'}) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 100),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Add the interceptor
    dio.interceptors.add(
      AuthInterceptor(
        getToken: () async {
          return await _auth.getAuthToken();
        },
      ),
    );
  }

  // Fetch favorites for a user
  Future<List<ProductModel>> fetchFavorites(String userId) async {
    try {
      final response = await dio.get('/favoris/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data['data'] ?? [];

        return responseData.map((item) {
          // Safely access nested product data
          final product = item['produit'] ?? {};
          final fournisseur = product['fournisseur'] ?? {};
          final promotion = product['promotion'];
          
          return ProductModel(
            id: product['_id']?.toString() ?? '',
            image: product['imageUrl']?.toString() ?? '',
            brandName: fournisseur['nom']?.toString() ?? 'Unknown Brand',
            title: product['nom']?.toString() ?? '',
            price: (product['prix'] is num) ? (product['prix'] as num).toDouble() : 0.0,
            priceAfetDiscount: (product['old_prix'] is num) ? (product['old_prix'] as num).toDouble() : null,
            dicountpercent: (promotion != null && promotion['pourcentage'] is num) ? promotion['pourcentage'] as int : 0,
            description: product['description']?.toString() ?? '',
            categoryId: product['category']?.toString(),
            categoryName: product['categoryName']?.toString(),
          );
        }).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch favorites');
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      throw Exception('Error fetching favorites: $e');
    }
  }

  Future<dynamic> addFavorite(String userId, String productId) async {
    try {
      print("product id $productId");
      print("user id $userId");

      final response = await dio.post(
        '/favoris',
        data: {
          'userId': userId,
          'produitId': productId,
        },
      );

      if (response.statusCode == 201) {
        print("success ${response.data}");
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add favorite');
      }
    } catch (e) {
      print('Error adding favorite: $e');
      throw Exception('Error adding favorite: $e');
    }
  }

  Future<bool> isFavorite(String userId, String productId) async {
    try {
      final response = await dio.get(
        '/favoris/is-favorited/$userId/$productId',
      );
      if (response.statusCode == 200) {
        return response.data['data']?['isFavorited'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  Future<dynamic> removeFavorite(String userId, String productId) async {
    try {
      final response = await dio.delete(
        '/favoris/$userId/$productId',
      );

      if (response.statusCode == 200) {
        print("removed favorite ${response.data}");
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to remove favorite');
      }
    } catch (e) {
      print('Error removing favorite: $e');
      throw Exception('Error removing favorite: $e');
    }
  }
}


