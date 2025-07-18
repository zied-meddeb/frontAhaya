import 'package:shop/models/product_model.dart';
import 'package:dio/dio.dart';

import 'auth_service.dart';
import 'dio_interceptor.dart';

class FavoritesService {
  final String baseUrl;
  late final Dio dio;
  final AuthService _auth = AuthService();

  // Constructor with optional baseUrl parameter for flexibility
  FavoritesService({this.baseUrl = 'http://10.0.2.2:3100/api'}) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
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
        final List<dynamic> responseData = response.data['data'];

        return responseData.map((item) => ProductModel(
          id: item['produit']['_id'] ?? '',
          image: item['produit']['imageUrl'] ?? '',
          brandName: item['produit']['fournisseur']['nom'] ?? 'Unknown Brand',
          title: item['produit']['nom'] ?? '',
          price: item['produit']['prix'].toDouble() ?? 0.0,
          priceAfetDiscount: item['produit']['old_prix']?.toDouble(),
          dicountpercent: item['produit']['promotion']?['pourcentage'] ?? 0,
          description: item['produit']['description'] ?? '',
        )).toList();
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      throw Exception('$e');
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
        throw Exception("$response['message']");
      }
    } catch (e) {
      return e;
    }
  }

  Future<bool> isFavorite(String userId, String productId) async {
    try {
      final response = await dio.get(
        '/favoris/is-favorited/$userId/$productId',
      );
      if (response.statusCode == 200) {

        return response.data['data']['isFavorited'];
      } else {
        return false;
      }

    } catch (e) {
      return false;
    }
  }
}


