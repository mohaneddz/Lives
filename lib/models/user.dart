enum UserType { registered, anonymous }

class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String userType;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String preferredLanguage;
  final DateTime registrationDate;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.userType,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.preferredLanguage,
    required this.registrationDate,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      userType: json['user_type'] as String,
      isEmailVerified: json['is_email_verified'] as bool,
      isPhoneVerified: json['is_phone_verified'] as bool,
      preferredLanguage: json['preferred_language'] as String,
      registrationDate: DateTime.parse(json['registration_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'user_type': userType,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'preferred_language': preferredLanguage,
      'registration_date': registrationDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? userType,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? preferredLanguage,
    DateTime? registrationDate,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      registrationDate: registrationDate ?? this.registrationDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserRegistrationRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String preferredLanguage;

  const UserRegistrationRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.preferredLanguage = 'en',
  });

  factory UserRegistrationRequest.fromJson(Map<String, dynamic> json) {
    return UserRegistrationRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'preferred_language': preferredLanguage,
    };
  }
}

class UserRegistrationResponse {
  final bool success;
  final String? message;
  final UserRegistrationData data;

  const UserRegistrationResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory UserRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return UserRegistrationResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: UserRegistrationData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class UserRegistrationData {
  final User user;
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const UserRegistrationData({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory UserRegistrationData.fromJson(Map<String, dynamic> json) {
    return UserRegistrationData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
    };
  }
}

// Add login request and response models
class UserLoginRequest {
  final String email;
  final String password;

  const UserLoginRequest({required this.email, required this.password});

  factory UserLoginRequest.fromJson(Map<String, dynamic> json) {
    return UserLoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class UserLoginResponse {
  final bool success;
  final String? message;
  final UserLoginData data;

  const UserLoginResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) {
    return UserLoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: UserLoginData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class UserLoginData {
  final User user;
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const UserLoginData({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory UserLoginData.fromJson(Map<String, dynamic> json) {
    return UserLoginData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
    };
  }
}

// Token refresh models
class TokenRefreshRequest {
  final String refreshToken;

  const TokenRefreshRequest({required this.refreshToken});

  factory TokenRefreshRequest.fromJson(Map<String, dynamic> json) {
    return TokenRefreshRequest(refreshToken: json['refresh_token'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'refresh_token': refreshToken};
  }
}

class TokenRefreshResponse {
  final bool success;
  final String? message;
  final TokenRefreshData data;

  const TokenRefreshResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: TokenRefreshData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class TokenRefreshData {
  final String accessToken;
  final String tokenType;

  const TokenRefreshData({required this.accessToken, required this.tokenType});

  factory TokenRefreshData.fromJson(Map<String, dynamic> json) {
    return TokenRefreshData(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'token_type': tokenType};
  }
}

// Email verification models
class SendVerificationEmailResponse {
  final bool success;
  final String message;
  final String? verificationToken; // For testing only

  const SendVerificationEmailResponse({
    required this.success,
    required this.message,
    this.verificationToken,
  });

  factory SendVerificationEmailResponse.fromJson(Map<String, dynamic> json) {
    return SendVerificationEmailResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      verificationToken: json['verification_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (verificationToken != null) 'verification_token': verificationToken,
    };
  }
}

class VerifyEmailResponse {
  final bool success;
  final String message;
  final User? user;

  const VerifyEmailResponse({
    required this.success,
    required this.message,
    this.user,
  });

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (user != null) 'user': user!.toJson(),
    };
  }
}
