import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/promotion.dart';
import 'package:dio/dio.dart';

import 'auth_service.dart';
import 'dio_interceptor.dart';
class PromotionService {
  final String baseUrl;
  late final Dio dio;
  PromotionService({this.baseUrl = 'http://localhost:3100/api'}){
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

  final AuthService _auth = AuthService();
  Future<Promotion> createPromotion(Promotion promotion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/promotions/'),

        body: jsonEncode(promotion.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return Promotion.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to create promotion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating promotion: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProducts(String fournisseurId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produits?fournisseur=$fournisseurId'),

      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}