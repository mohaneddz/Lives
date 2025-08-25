import 'user.dart';

enum ContributorType { individual, association }

enum VerificationStatus { pending, verified, rejected }

class Contributor {
  final int id;
  final int userId;
  final String contributorType;
  final String verificationStatus;
  final bool verified;
  final String motivation;
  final DateTime createdAt;
  // Additional properties for UI compatibility
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? organizationName;

  const Contributor({
    required this.id,
    required this.userId,
    required this.contributorType,
    required this.verificationStatus,
    required this.verified,
    required this.motivation,
    required this.createdAt,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.organizationName,
  });

  factory Contributor.fromJson(Map<String, dynamic> json) {
    return Contributor(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      contributorType: json['contributor_type'] as String,
      verificationStatus: json['verification_status'] as String,
      verified: json['verified'] as bool,
      motivation: json['motivation'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      organizationName: json['organization_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'contributor_type': contributorType,
      'verification_status': verificationStatus,
      'verified': verified,
      'motivation': motivation,
      'created_at': createdAt.toIso8601String(),
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (organizationName != null) 'organization_name': organizationName,
    };
  }

  Contributor copyWith({
    int? id,
    int? userId,
    String? contributorType,
    String? verificationStatus,
    bool? verified,
    String? motivation,
    DateTime? createdAt,
  }) {
    return Contributor(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contributorType: contributorType ?? this.contributorType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verified: verified ?? this.verified,
      motivation: motivation ?? this.motivation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ContributorRegistrationRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String contributorType;
  final String motivation;

  const ContributorRegistrationRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.contributorType,
    required this.motivation,
  });

  factory ContributorRegistrationRequest.fromJson(Map<String, dynamic> json) {
    return ContributorRegistrationRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      contributorType: json['contributor_type'] as String,
      motivation: json['motivation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'contributor_type': contributorType,
      'motivation': motivation,
    };
  }
}

class ContributorRegistrationResponse {
  final bool success;
  final String? message;
  final ContributorRegistrationData data;

  const ContributorRegistrationResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory ContributorRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return ContributorRegistrationResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: ContributorRegistrationData.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class ContributorRegistrationData {
  final User user;
  final Contributor contributor;
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const ContributorRegistrationData({
    required this.user,
    required this.contributor,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory ContributorRegistrationData.fromJson(Map<String, dynamic> json) {
    return ContributorRegistrationData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      contributor: Contributor.fromJson(
        json['contributor'] as Map<String, dynamic>,
      ),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'contributor': contributor.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
    };
  }
}

class ContributorLoginRequest {
  final String email;
  final String password;

  const ContributorLoginRequest({required this.email, required this.password});

  factory ContributorLoginRequest.fromJson(Map<String, dynamic> json) {
    return ContributorLoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class ContributorLoginResponse {
  final bool success;
  final String? message;
  final ContributorLoginData data;

  const ContributorLoginResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory ContributorLoginResponse.fromJson(Map<String, dynamic> json) {
    return ContributorLoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: ContributorLoginData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class ContributorLoginData {
  final User user;
  final Contributor contributor;
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const ContributorLoginData({
    required this.user,
    required this.contributor,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory ContributorLoginData.fromJson(Map<String, dynamic> json) {
    return ContributorLoginData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      contributor: Contributor.fromJson(
        json['contributor'] as Map<String, dynamic>,
      ),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'contributor': contributor.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
    };
  }
}
