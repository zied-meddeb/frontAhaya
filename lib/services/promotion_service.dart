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
    required String titre,
    required String description,
    required double prixOriginal,
    required double prixOffre,
    required DateTime dateDebut,
    required DateTime dateFin,
    DateTime? dateAffiche,
    required String fournisseurId,
    required String statut,
    required List<Map<String, dynamic>> produits,
    List<XFile>? afficheImages,
    List<XFile>? productImages, // Add product images parameter
  }) async {
    try {
      print('PromotionService: Creating promotion with ${productImages?.length ?? 0} product images');
      
      // Create FormData for multipart request
      Map<String, dynamic> formFields = {
        'type': type,
        'titre': titre,
        'description': description,
        'prix_original': prixOriginal,
        'prix_offre': prixOffre,
        'date_debut': dateDebut.toIso8601String(),
        'date_fin': dateFin.toIso8601String(),
        'Fournisseur': fournisseurId,
        'statut': statut,
        'produits': jsonEncode(produits), 
      };

      // Add dateAffiche only if provided
      if (dateAffiche != null) {
        formFields['date_affiche'] = dateAffiche.toIso8601String();
      }

      FormData formData = FormData.fromMap(formFields);

      // Add multiple images if provided
      if (afficheImages != null && afficheImages.isNotEmpty) {
        for (int i = 0; i < afficheImages.length; i++) {
          final image = afficheImages[i];
          if (kIsWeb) {
            // For web platform, read bytes directly
            final bytes = await image.readAsBytes();
            formData.files.add(MapEntry(
              'affiches', // Backend expects 'affiches' for multiple files
              MultipartFile.fromBytes(
                bytes,
                filename: image.name,
              ),
            ));
          } else {
            // For mobile platforms, use fromFile
            formData.files.add(MapEntry(
              'affiches',
              await MultipartFile.fromFile(
                image.path,
                filename: image.name,
              ),
            ));
          }
        }
      }

      // Add product images if provided
      if (productImages != null && productImages.isNotEmpty) {
        print('PromotionService: Adding ${productImages.length} product images to FormData');
        for (int i = 0; i < productImages.length; i++) {
          final image = productImages[i];
          print('PromotionService: Adding product image ${i + 1}: ${image.name}');
          if (kIsWeb) {
            // For web platform, read bytes directly
            final bytes = await image.readAsBytes();
            print('PromotionService: Web - Adding product image bytes (${bytes.length} bytes)');
            formData.files.add(MapEntry(
              'productImages', // Backend expects 'productImages' for product images
              MultipartFile.fromBytes(
                bytes,
                filename: image.name,
              ),
            ));
          } else {
            // For mobile platforms, use fromFile
            print('PromotionService: Mobile - Adding product image from file path: ${image.path}');
            formData.files.add(MapEntry(
              'productImages',
              await MultipartFile.fromFile(
                image.path,
                filename: image.name,
              ),
            ));
          }
        }
      } else {
        print('PromotionService: No product images provided or list is empty');
        print('PromotionService: productImages == null: ${productImages == null}');
        print('PromotionService: productImages isEmpty: ${productImages?.isEmpty}');
      }

      print('PromotionService: Final FormData files count: ${formData.files.length}');
      print('PromotionService: FormData files:');
      for (var file in formData.files) {
        print('  - ${file.key}: ${file.value.filename}');
      }
      print("form dataaaaa: ${formData.fields}");
      final response = await dio.post(
        '/promotion/',
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
        '/produit/byfournisseur/$fournisseurId',
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

  Future<List<Map<String, dynamic>>> fetchPromotionsByFournisseurId(String fournisseurId) async {
    try {
      final token = await _auth.getAuthToken();
      print('Fetching promotions for fournisseurId: $fournisseurId with token: $token');
      final response = await dio.get(
        '/promotion/fournisseur/$fournisseurId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> promotions = response.data['data'] ?? [];
        return promotions.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch promotions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching promotions: $e');
    }
  }

  Future<Map<String, dynamic>> fetchPromotionById(String? id) async {
    try {
      final response = await dio.get(
        '/promotion/$id',
      );
      if (response.statusCode == 200) {
        final  promotion = response.data['data'] ?? [];
        return promotion;
      } else {
        throw Exception('Failed to fetch promotions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching promotions: $e');
    }
  }

  Future<Promotion> updatePromotion({
    required String promotionId,
    required String type,
    required String titre,
    required String description,
    required double prixOriginal,
    required double prixOffre,
    required DateTime dateDebut,
    required DateTime dateFin,
    DateTime? dateAffiche,
    required String fournisseurId,
    required String statut,
    required List<Map<String, dynamic>> produits,
    List<XFile>? afficheImages,
    List<XFile>? productImages,
    required List<String> existingAfficheUrls,
  }) async {
    try {
      // Validate we have at least one image (existing or new)
      if ((afficheImages == null || afficheImages.isEmpty) &&
          (existingAfficheUrls.isEmpty)) {
        throw Exception('At least one promotion image is required (either existing or new)');
      }

      // Create FormData
      final formData = FormData.fromMap({
        'type': type,
        'titre': titre,
        'description': description,
        'prix_original': prixOriginal.toString(),
        'prix_offre': prixOffre.toString(),
        'date_debut': dateDebut.toIso8601String(),
        'date_fin': dateFin.toIso8601String(),
        'Fournisseur': fournisseurId,
        'statut': statut,
        'produits': jsonEncode(produits),
        'existingAfficheUrls': jsonEncode(existingAfficheUrls),
        if (dateAffiche != null) 'date_affiche': dateAffiche.toIso8601String(),
      });

      // Add affiche images if any
      if (afficheImages != null && afficheImages.isNotEmpty) {
        for (final image in afficheImages) {
          MultipartFile file;
          if (kIsWeb) {
            final bytes = await image.readAsBytes();
            file = MultipartFile.fromBytes(
              bytes,
              filename: image.name,
            );
          } else {
            file = await MultipartFile.fromFile(
              image.path,
              filename: image.name,
            );
          }
          formData.files.add(MapEntry('affiches', file));
        }
      }

      // Add product images if any
      if (productImages != null && productImages.isNotEmpty) {
        for (final image in productImages) {
          MultipartFile file;
          if (kIsWeb) {
            final bytes = await image.readAsBytes();
            file = MultipartFile.fromBytes(
              bytes,
              filename: image.name,
            );
          } else {
            file = await MultipartFile.fromFile(
              image.path,
              filename: image.name,
            );
          }
          formData.files.add(MapEntry('productImages', file));
        }
      }

      final response = await dio.post(
        '/promotion/$promotionId',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Promotion updated successfully: ${response.data}');
        final responseData = response.data;
        if (responseData['data'] != null && responseData['data']['data'] != null) {
          return Promotion.fromJson(responseData['data']['data']);
        } else if (responseData['data'] != null) {
          return Promotion.fromJson(responseData['data']);
        } else {
          return Promotion.fromJson(responseData);
        }
      } else {
        throw Exception('Failed to update promotion: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to update promotion: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Failed to update promotion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error updating promotion: $e - ${e.toString()} - ${e.runtimeType}');
    }
  }
}
