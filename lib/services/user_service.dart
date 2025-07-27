import 'package:dio/dio.dart';

import 'auth_service.dart';
import 'dio_interceptor.dart';

class UserService {
  final String baseUrl;
  late final Dio dio;
  UserService({this.baseUrl = 'http://localhost:3100/api'}){
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


  /// Authenticates a user with email and password
  /// Returns [true] on success, throws [AuthException] on failure
  Future<bool> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw AuthException('Email and password are required');
      }

      final response = await dio.post(
        '$baseUrl/user/auth/login',
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

      final userData = decodedResponse['data'];
      await _auth.saveCredentials(
         userData['email'] ?? email,
         userData['nom'],
         userData['id'],
      );
      await _auth.saveAuthToken(userData['token']);

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

  /// Registers a new user account
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
        '$baseUrl/user',
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
      final response= await dio.post('$baseUrl/user/auth/verify',
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

  Future<bool> deleteUnverifiedUser(email) async {
    try{
      final response= await dio.delete('$baseUrl/user/not-verified/$email');
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
      final response= await dio.post('$baseUrl/user/send-verification-code',
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

  Future<bool> updateUserPreferences( userId, List<dynamic> categories) async {
    try {
      final response = await dio.put(
        '$baseUrl/user/preferences/$userId',
        data: {
          'favoriteCategories': categories.map((cat) => cat.id).toList(),
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      } else {
        throw AuthException(response.data['message'] ?? 'Unknown error occurred');
      }
    } on DioError catch (e) {
      throw AuthException(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw AuthException('Failed to update preferences: ${e.toString()}');
    }
  }

  Future<dynamic> getUserPreferences(userId) async {

    try {
      final response = await dio.get(
        '$baseUrl/user/preferences/$userId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data["data"];
      } else {
        throw AuthException(response.data['message'] ?? 'Unknown error occurred');
      }
    } on DioError catch (e) {
      throw AuthException(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw AuthException('Failed to update preferences: ${e.toString()}');
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
