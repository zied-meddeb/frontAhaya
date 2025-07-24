import 'dart:convert';
import 'dart:typed_data';
import '../models/promotion.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'dio_interceptor.dart';

class PromotionService {
  final String baseUrl;
  late final Dio dio;
  final AuthService _auth = AuthService();

  PromotionService({this.baseUrl = 'http://localhost:3100/api'}) {
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

  Future<Promotion> createPromotion({
    required String type,
    required String description,
    required double prixOriginal,
    required double prixOffre,
    required DateTime dateDebut,
    required DateTime dateFin,
    required String fournisseurId,
    required String statut,
    required List<Map<String, dynamic>> produits,
    XFile? afficheImage,
  }) async {
    try {
      // Create FormData for multipart request
      FormData formData = FormData.fromMap({
        'type': type,
        'description': description,
        'prix_original': prixOriginal,
        'prix_offre': prixOffre,
        'date_debut': dateDebut.toIso8601String(),
        'date_fin': dateFin.toIso8601String(),
        'Fournisseur': fournisseurId,
        'statut': statut,
        'produits': jsonEncode(produits),
      });

      // Add image if provided
      if (afficheImage != null) {
        if (kIsWeb) {
          // For web platform, read bytes directly
          final bytes = await afficheImage.readAsBytes();
          formData.files.add(MapEntry(
            'affiche',
            MultipartFile.fromBytes(
              bytes,
              filename: afficheImage.name,
            ),
          ));
        } else {
          // For mobile platforms, use fromFile
          formData.files.add(MapEntry(
            'affiche',
            await MultipartFile.fromFile(
              afficheImage.path,
              filename: afficheImage.name,
            ),
          ));
        }
      }

      final response = await dio.post(
        '/promotion',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Promotion.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create promotion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating promotion: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProducts(String fournisseurId) async {
    try {
      final response = await dio.get(
        '/produit',
        queryParameters: {'fournisseur': fournisseurId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> products = response.data['data'] ?? [];
        return products.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}