
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();


  // Save login credentials
  Future<void> saveCredentials(String email, String nom,String id, {String? role}) async {
    await _storage.write(key: 'id', value: id);
    await _storage.write(key: 'nom', value: nom);
    await _storage.write(key: 'email', value: email);
    if (role != null) {
      await _storage.write(key: 'role', value: role);
    }
  }

  // Get stored login credentials
  Future<Map<String, String>> getCredentials() async {
    String? id = await _storage.read(key: 'id');
    String? email = await _storage.read(key: 'email');
    String? nom = await _storage.read(key: 'nom');
    String? role = await _storage.read(key: 'role');
    return {'email': email ?? '','nom': nom ?? '','id': id ?? '', 'role': role ?? ''};
  }
  // Get stored login credentials
  Future<String?> getUserId() async {
    String? id = await _storage.read(key: 'id');

    return id;
  }

  // Save auth token (more common for login persistence)
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  // Get stored auth token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'token');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    String? token = await getAuthToken();
    return token != null;
  }

  // Clear all stored credentials (logout)
  Future<void> clearCredentials() async {
    await _storage.delete(key: 'id');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'password');
    await _storage.delete(key: 'nom');
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'role');
  }

  // Get user role
  Future<String?> getUserRole() async {
    return await _storage.read(key: 'role');
  }

  Future<void> saveLanguage(String language) async {
    await _storage.write(key: 'language', value: language);

  }

  Future<String?> getLanguage() async {
    return await _storage.read(key: 'language');
  }


}
