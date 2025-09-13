import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/contributor.dart';
import '../models/verification.dart';

class AuthService {
  static const String _baseUrl =
      'https://your-api-base-url.com'; // Replace with actual API URL

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Register a new user
  Future<UserRegistrationResponse> registerUser(
    UserRegistrationRequest request,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/users');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return UserRegistrationResponse.fromJson(responseData);
      } else {
        throw AuthException('Failed to register user: ${response.statusCode}');
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
  Future<ApiResponse<Map<String, dynamic>>> registerContributor(
    ContributorRegistrationRequest request,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/contributors');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>.fromJson(
          responseData,
          (json) => json as Map<String, dynamic>,
        );
      } else {
        throw AuthException(
          'Failed to register contributor: ${response.statusCode}',
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

  // Verify email with code
  Future<EmailVerificationResponse> verifyEmail(
    EmailVerificationRequest request,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/users/validate-email');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return EmailVerificationResponse.fromJson(responseData);
      } else {
        throw AuthException(
          'Email verification failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is SocketException) {
        throw AuthException('No internet connection');
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Email verification failed: $e');
      }
    }
  }

  // Resend verification email
  Future<ApiResponse<Map<String, dynamic>>> resendVerificationEmail(
    ResendVerificationRequest request,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/users/resend-verification-email');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>.fromJson(
          responseData,
          (json) => json as Map<String, dynamic>,
        );
      } else {
        throw AuthException(
          'Failed to resend verification email: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is SocketException) {
        throw AuthException('No internet connection');
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Failed to resend verification email: $e');
      }
    }
  }

  // Get user profile (if needed)
  Future<ApiResponse<User>> getUserProfile(int userId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$userId');
      final response = await http.get(
        url,
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ApiResponse<User>.fromJson(
          responseData,
          (json) => User.fromJson(json as Map<String, dynamic>),
        );
      } else {
        throw AuthException(
          'Failed to get user profile: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is SocketException) {
        throw AuthException('No internet connection');
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Failed to get user profile: $e');
      }
    }
  }

  // Create UserRegistrationRequest helper
  static UserRegistrationRequest createUserRegistrationRequest({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) {
    return UserRegistrationRequest(
      userType: 'registered',
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      isEmailVerified: false,
      registrationDate: DateTime.now(),
    );
  }

  // Create ContributorRegistrationRequest helper for individual
  static ContributorRegistrationRequest createIndividualContributorRequest({
    required int userId,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? idCardPicture,
    String? selfiePicture,
  }) {
    return ContributorRegistrationRequest(
      userId: userId,
      contributorType: 'individual',
      verificationStatus: 'pending',
      verified: false,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      idCardPicture: idCardPicture,
      selfiePicture: selfiePicture,
      organizationName: null,
      organizationAddress: null,
      registrationCertificatePicture: null,
    );
  }

  // Create ContributorRegistrationRequest helper for association
  static ContributorRegistrationRequest createAssociationContributorRequest({
    required int userId,
    required String email,
    required String phoneNumber,
    required String organizationName,
    required String organizationAddress,
    String? registrationCertificatePicture,
  }) {
    return ContributorRegistrationRequest(
      userId: userId,
      contributorType: 'association',
      verificationStatus: 'pending',
      verified: false,
      email: email,
      firstName: null,
      lastName: null,
      phoneNumber: phoneNumber,
      idCardPicture: null,
      selfiePicture: null,
      organizationName: organizationName,
      organizationAddress: organizationAddress,
      registrationCertificatePicture: registrationCertificatePicture,
    );
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
