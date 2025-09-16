import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/contributor.dart';
import 'token_storage_service.dart';

class AuthService {
  // Use your computer's IP address instead of localhost for device access
  static const String _baseUrl = 'http://192.168.100.23:5000/api';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Register a new user
  Future<UserRegistrationResponse> registerUser(
    UserRegistrationRequest request,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/register/user');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final userResponse = UserRegistrationResponse.fromJson(responseData);

        // Store authentication data
        await TokenStorageService.storeAuthData(
          accessToken: userResponse.data.accessToken,
          refreshToken: userResponse.data.refreshToken,
          tokenType: userResponse.data.tokenType,
          userData: userResponse.data.user.toJson(),
        );

        return userResponse;
      } else {
        final errorData = json.decode(response.body);
        throw AuthException(errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      if (e is SocketException) {
        throw AuthException('No internet connection');
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Registration failed: $e');
      }
    }
  }

  // Register a contributor
  Future<ContributorRegistrationResponse> registerContributor(
    ContributorRegistrationRequest request,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/register/contributor');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final contributorResponse = ContributorRegistrationResponse.fromJson(
          responseData,
        );

        // Store authentication data
        await TokenStorageService.storeAuthData(
          accessToken: contributorResponse.data.accessToken,
          refreshToken: contributorResponse.data.refreshToken,
          tokenType: contributorResponse.data.tokenType,
          userData: contributorResponse.data.user.toJson(),
          contributorData: contributorResponse.data.contributor.toJson(),
        );

        return contributorResponse;
      } else {
        final errorData = json.decode(response.body);
        throw AuthException(
          errorData['message'] ?? 'Contributor registration failed',
        );
      }
    } catch (e) {
      if (e is SocketException) {
        throw AuthException('No internet connection');
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Contributor registration failed: $e');
      }
    }
  }

  // User login
  Future<UserLoginResponse> loginUser(UserLoginRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/login/user');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final loginResponse = UserLoginResponse.fromJson(responseData);

        // Store authentication data
        await TokenStorageService.storeAuthData(
          accessToken: loginResponse.data.accessToken,
          refreshToken: loginResponse.data.refreshToken,
          tokenType: loginResponse.data.tokenType,
          userData: loginResponse.data.user.toJson(),
        );

        return loginResponse;
      } else {
        final errorData = json.decode(response.body);
        throw AuthException(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is SocketException) {
        throw AuthException('No internet connection');
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Login failed: $e');
      }
    }
  }

  // Contributor login
  Future<ContributorLoginResponse> loginContributor(
    ContributorLoginRequest request,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/login/contributor');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final loginResponse = ContributorLoginResponse.fromJson(responseData);

        // Store authentication data
        await TokenStorageService.storeAuthData(
          accessToken: loginResponse.data.accessToken,
          refreshToken: loginResponse.data.refreshToken,
          tokenType: loginResponse.data.tokenType,
          userData: loginResponse.data.user.toJson(),
          contributorData: loginResponse.data.contributor.toJson(),
        );

        return loginResponse;
      } else {
        final errorData = json.decode(response.body);
        throw AuthException(errorData['message'] ?? 'Contributor login failed');
      }
    } catch (e) {
      if (e is SocketException) {
        throw AuthException('No internet connection');
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Contributor login failed: $e');
      }
    }
  }

  // Token refresh
  Future<TokenRefreshResponse> refreshToken() async {
    try {
      final refreshToken = await TokenStorageService.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException('No refresh token available');
      }

      final request = TokenRefreshRequest(refreshToken: refreshToken);
      final url = Uri.parse('$_baseUrl/auth/refresh');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final refreshResponse = TokenRefreshResponse.fromJson(responseData);

        // Update stored tokens
        await TokenStorageService.updateAccessToken(
          accessToken: refreshResponse.data.accessToken,
          tokenType: refreshResponse.data.tokenType,
        );

        return refreshResponse;
      } else {
        final errorData = json.decode(response.body);
        throw AuthException(errorData['message'] ?? 'Token refresh failed');
      }
    } catch (e) {
      if (e is SocketException) {
        throw AuthException('No internet connection');
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Token refresh failed: $e');
      }
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await TokenStorageService.clearAuthData();
    } catch (e) {
      throw AuthException('Logout failed: $e');
    }
  }

  // Check if authenticated
  Future<bool> isAuthenticated() async {
    return await TokenStorageService.isAuthenticated();
  }

  // Get current user data
  Future<User?> getCurrentUser() async {
    try {
      final userData = await TokenStorageService.getUserData();
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get current contributor data
  Future<Contributor?> getCurrentContributor() async {
    try {
      final contributorData = await TokenStorageService.getContributorData();
      if (contributorData != null) {
        return Contributor.fromJson(contributorData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Make authenticated request with automatic token refresh
  Future<http.Response> makeAuthenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool retry = true,
  }) async {
    final authHeaders = await TokenStorageService.getAuthHeaders();
    if (authHeaders == null) {
      throw AuthException('User not authenticated');
    }

    final url = Uri.parse('$_baseUrl$endpoint');
    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: authHeaders);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: authHeaders,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: authHeaders,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: authHeaders);
          break;
        default:
          throw AuthException('Unsupported HTTP method: $method');
      }

      // If unauthorized and we haven't retried yet, try refreshing token
      if (response.statusCode == 401 && retry) {
        try {
          await refreshToken();
          return makeAuthenticatedRequest(
            method: method,
            endpoint: endpoint,
            body: body,
            retry: false,
          );
        } catch (e) {
          // Refresh failed, user needs to login again
          await logout();
          throw AuthException('Session expired. Please login again.');
        }
      }

      return response;
    } catch (e) {
      if (e is SocketException) {
        throw AuthException('No internet connection');
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Request failed: $e');
      }
    }
  }
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  final String? type;

  const AuthException(this.message, {this.statusCode, this.type});

  factory AuthException.fromResponse(
    Map<String, dynamic> errorData,
    int statusCode,
  ) {
    return AuthException(
      errorData['message'] ?? 'Unknown error occurred',
      statusCode: statusCode,
      type: errorData['error'] ?? 'UNKNOWN_ERROR',
    );
  }

  factory AuthException.networkError() {
    return const AuthException(
      'No internet connection. Please check your network and try again.',
      type: 'NETWORK_ERROR',
    );
  }

  factory AuthException.timeout() {
    return const AuthException(
      'Request timed out. Please try again.',
      type: 'TIMEOUT_ERROR',
    );
  }

  factory AuthException.serverError() {
    return const AuthException(
      'Server error occurred. Please try again later.',
      type: 'SERVER_ERROR',
    );
  }

  factory AuthException.unauthorized() {
    return const AuthException(
      'Session expired. Please login again.',
      statusCode: 401,
      type: 'UNAUTHORIZED',
    );
  }

  bool get isNetworkError => type == 'NETWORK_ERROR';
  bool get isUnauthorized => statusCode == 401 || type == 'UNAUTHORIZED';
  bool get isServerError =>
      (statusCode != null && statusCode! >= 500) || type == 'SERVER_ERROR';
  bool get isValidationError => statusCode == 400;

  @override
  String toString() => 'AuthException: $message';
}
