import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userDataKey = 'user_data';
  static const String _contributorDataKey = 'contributor_data';

  // Use secure storage for tokens
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Store access token
  static Future<void> storeAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  // Store refresh token
  static Future<void> storeRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  // Store token type
  static Future<void> storeTokenType(String tokenType) async {
    await _secureStorage.write(key: _tokenTypeKey, value: tokenType);
  }

  // Store user data (non-sensitive)
  static Future<void> storeUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  // Store contributor data (non-sensitive)
  static Future<void> storeContributorData(
    Map<String, dynamic> contributorData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_contributorDataKey, json.encode(contributorData));
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Get token type
  static Future<String?> getTokenType() async {
    return await _secureStorage.read(key: _tokenTypeKey);
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return json.decode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  // Get contributor data
  static Future<Map<String, dynamic>?> getContributorData() async {
    final prefs = await SharedPreferences.getInstance();
    final contributorDataString = prefs.getString(_contributorDataKey);
    if (contributorDataString != null) {
      return json.decode(contributorDataString) as Map<String, dynamic>;
    }
    return null;
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Get authorization header
  static Future<Map<String, String>?> getAuthHeaders() async {
    final accessToken = await getAccessToken();
    final tokenType = await getTokenType() ?? 'Bearer';

    if (accessToken != null) {
      return {
        'Authorization': '$tokenType $accessToken',
        'Content-Type': 'application/json',
      };
    }
    return null;
  }

  // Store complete authentication data
  static Future<void> storeAuthData({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required Map<String, dynamic> userData,
    Map<String, dynamic>? contributorData,
  }) async {
    await Future.wait([
      storeAccessToken(accessToken),
      storeRefreshToken(refreshToken),
      storeTokenType(tokenType),
      storeUserData(userData),
      if (contributorData != null) storeContributorData(contributorData),
    ]);
  }

  // Clear all authentication data
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _tokenTypeKey),
      prefs.remove(_userDataKey),
      prefs.remove(_contributorDataKey),
    ]);
  }

  // Update only access token (for refresh)
  static Future<void> updateAccessToken({
    required String accessToken,
    required String tokenType,
  }) async {
    await Future.wait([
      storeAccessToken(accessToken),
      storeTokenType(tokenType),
    ]);
  }
}
