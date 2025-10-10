import 'package:dio/dio.dart';
import 'package:shop/config/environment.dart';

import 'auth_service.dart';
import 'dio_interceptor.dart';

class ProductService {
  final String baseUrl;
  late final Dio dio;
  final AuthService _auth = AuthService();

  // Constructor with optional baseUrl parameter for flexibility
  ProductService({String? baseUrl}) : baseUrl = baseUrl ?? Environment.baseUrl {
    dio = Dio(BaseOptions(
      baseUrl: this.baseUrl,
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

  /// Fetches all products with pagination
  Future<Map<String, dynamic>> getAllProducts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/produit',
        queryParameters: {'page': page, 'limit': limit},
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gets single product by ID
  Future<Map<String, dynamic>> getProductById(String productId) async {
    try {
      final response = await dio.get('$baseUrl/produit/$productId');
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Searches products with criteria
  Future<Map<String, dynamic>> searchProducts({
    String? query,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? fournisseur,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/produit/search/criteria',
        queryParameters: {
          if (query != null) 'nom': query,
          if (minPrice != null) 'priceMin': minPrice,
          if (maxPrice != null) 'priceMax': maxPrice,
          if (category != null) 'category': category,
          if (fournisseur != null) 'fournisseur': fournisseur,
          'limit': limit,
        },
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gets popular products
  Future<Map<String, dynamic>> getPopularProducts({int limit = 10}) async {
    try {
      final response = await dio.get(
        '$baseUrl/produit/search/popular',
        queryParameters: {'limit': limit},
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gets popular products
  Future<Map<String, dynamic>> getProductByCriteria(String nom) async {
    try {
      final response = await dio.get(
        '$baseUrl/produit/search/criteria',
        queryParameters: {'nom': nom},
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gets products by category
  Future<Map<String, dynamic>> getProductsByCategory(
      String categoryId, {
        int limit = 10,
      }) async {
    try {
      final response = await dio.get(
        '$baseUrl/produit/category/$categoryId',
        queryParameters: {'limit': limit},
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gets best discount products
  Future<Map<String, dynamic>> getBestDiscountProducts({int limit = 10}) async {
    try {
      final response = await dio.get(
        '$baseUrl/produit/best-discount',
        queryParameters: {'limit': limit},
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Tracks product view (increments view count)
  Future<void> trackProductView(String productId) async {
    try {
      await dio.put('$baseUrl/produit/views/$productId');
    } on DioException catch (e) {
    print('Failed to track product view: ${e.message}');
    }
  }

  // Helper method to handle successful responses
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data;
    }
    throw Exception(response.data['message'] ?? 'Failed to load data');
  }

  // Helper method to handle Dio errors
  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 404) {
      return Exception('Resource not found');
    }
    return Exception(
      e.response?.data['message'] ?? 'Network error: ${e.message}',
    );
  }
}
