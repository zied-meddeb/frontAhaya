
import 'package:dio/dio.dart';

import 'auth_service.dart';
import 'dio_interceptor.dart';

class CategoriesService {
  final String baseUrl;
  late final Dio dio;
  final AuthService _auth = AuthService();

  //http://10.0.2.2:3100
  //http://localhost:3100
  CategoriesService({this.baseUrl = 'http://localhost:3100/api'}) {
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
  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await dio.get('/category');
      if (response.statusCode == 200) {
        return  response.data['data'];
      } else {
        throw Exception('Failed to load Categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Categories: $e');
    }
  }

  Future<dynamic> addCategories(String userId, String productId) async {
    try {

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
}


