import 'package:dio/dio.dart';

import 'auth_service.dart';
import 'dio_interceptor.dart';

class FournisseurService {
  final String baseUrl;
  late final Dio dio;
  FournisseurService({this.baseUrl = 'http://10.0.2.2:3100/api'}){
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


  /// Authenticates a Fournisseur with email and password
  /// Returns [true] on success, throws [AuthException] on failure
  Future<bool> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw AuthException('Email and password are required');
      }

      final response = await dio.post(
        '$baseUrl/fournisseur/auth/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          validateStatus: (status) => status == 200,
        ),
      );

      final decodedResponse = response.data;

      // Validate response structure
      if (decodedResponse['success'] != true ||
          decodedResponse['data'] == null ||
          decodedResponse['data']['token'] == null) {
        throw AuthException('Invalid server response format');
      }

      final fournisseurData = decodedResponse['data'];
      await _auth.saveCredentials(
        fournisseurData['email'] ?? email,
        fournisseurData['nom'],
        fournisseurData['id'],
      );
      await _auth.saveAuthToken(fournisseurData['token']);

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid email or password');
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        throw AuthException(e.response!.data['message']);
      }
      throw AuthException('Login failed: ${e.message}');
    } catch (e) {
      throw AuthException('An unexpected error occurred');
    }
  }

  /// Registers a new fournisseur account
  /// Returns [true] on success, throws [AuthException] on failure
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw AuthException('All fields are required');
      }

      if (password.length < 6) {
        throw AuthException('Password must be at least 6 characters');
      }

      final response = await dio.post(
        '$baseUrl/fournisseur',
        data: {
          'email': email,
          'password': password,
          'nom': name,
        },
        options: Options(
          validateStatus: (status) => status == 201,
        ),
      );

      final decodedResponse = response.data;

      if (decodedResponse['success'] != true) {
        throw AuthException(decodedResponse['message'] ?? 'Registration failed');
      }

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw AuthException('Email already in use');
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        throw AuthException(e.response!.data['message']);
      }
      throw AuthException('Registration failed: ${e.message}');
    } catch (e) {
      throw AuthException('An unexpected error occurred');
    }
  }


  Future<bool> verifyEmail(email,code) async {
    try{
      final response= await dio.post('$baseUrl/fournisseur/auth/verify',
          data: {
            'email': email,
            'code': code,
          });
      if(response.statusCode==200 && response.data['success']){
        await _auth.saveCredentials(
          response.data['data']['email'] ?? email,
          response.data['data']['nom'],
          response.data['data']['id'],
        );
        await _auth.saveAuthToken( response.data['data']['token']);
        return true;
      }else{
        throw AuthException(response.data['message']);

      }
    }on DioException catch(e){
      throw AuthException(e.response?.data['message']);
    }

  }

  Future<bool> deleteUnverifiedfournisseur(email) async {
    try{
      final response= await dio.delete('$baseUrl/fournisseur/not-verified/$email');
      if(response.statusCode==200 && response.data['success']){
        return true;
      }else{
        throw AuthException(response.data['message']);

      }
    } catch(e){
      throw AuthException(e.toString());
    }

  }



  Future<bool> sendVerificationCode(email) async {
    try{
      final response= await dio.post('$baseUrl/fournisseur/send-verification-code',
          data: {
            'email': email,});
      if(response.statusCode==200 && response.data['success']){
        return true;
      }else{
        throw AuthException(response.data['message']);

      }
    } catch(e){
      throw AuthException(e.toString());
    }

  }


}








class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

abstract class AuthStorage {
  Future<void> saveCredentials({
    required String email,
    required String? name,
    required String? userId,
  });

  Future<void> saveAuthToken(String token);
}
