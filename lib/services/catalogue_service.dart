import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'auth_service.dart';
import 'dio_interceptor.dart';

class CatalogueService {
  final String baseUrl;
  late final Dio dio;
  final AuthService _auth = AuthService();

  CatalogueService({this.baseUrl = 'http://10.0.2.2:3100/api'}) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 100),
      receiveTimeout: const Duration(seconds: 100),
    ));
    dio.interceptors.add(
      AuthInterceptor(
        getToken: () async {
          return await _auth.getAuthToken();
        },
      ),
    );
  }

  // Get all catalogues for a fournisseur
  Future<List<Map<String, dynamic>>> fetchCataloguesByFournisseur(String fournisseurId) async {
    try {
      final response = await dio.get('/catalogue/fournisseur/$fournisseurId');

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      } else {
        throw Exception('Failed to fetch catalogues: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching catalogues: $e');
    }
  }

  // Get a single catalogue by ID
  Future<Map<String, dynamic>> fetchCatalogueById(String catalogueId) async {
    try {
      final response = await dio.get('/catalogue/$catalogueId');

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to fetch catalogue: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching catalogue: $e');
    }
  }

  // Create a new catalogue
  Future<Map<String, dynamic>> createCatalogue({
    required String fournisseurId,
    required String name,
  }) async {
    try {
      final response = await dio.post(
        '/catalogue',
        data: {
          'Fournisseur': fournisseurId,
          'name': name,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to create catalogue: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Error creating catalogue: $e');
    }
  }

  // Update a catalogue
  Future<Map<String, dynamic>> updateCatalogue({
    required String catalogueId,
    required String name,
  }) async {
    try {
      final response = await dio.put(
        '/catalogue/$catalogueId',
        data: {
          'name': name,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to update catalogue: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Error updating catalogue: $e');
    }
  }

  // Delete a catalogue
  Future<void> deleteCatalogue(String catalogueId) async {
    try {
      final response = await dio.delete('/catalogue/$catalogueId');

      if (response.data['success'] != true) {
        throw Exception('Failed to delete catalogue: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Error deleting catalogue: $e');
    }
  }

  // Add a page to a catalogue
  Future<Map<String, dynamic>> addPageToCatalogue({
    required String catalogueId,
    required XFile imageFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
        ),
      });

      final response = await dio.post(
        '/catalogue/$catalogueId/pages',
        data: formData,
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to add page: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Error adding page to catalogue: $e');
    }
  }

  // Remove a page from a catalogue
  Future<Map<String, dynamic>> removePageFromCatalogue({
    required String catalogueId,
    required int pageIndex,
  }) async {
    try {
      final response = await dio.delete('/catalogue/$catalogueId/pages/$pageIndex');

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to remove page: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Error removing page from catalogue: $e');
    }
  }
}
