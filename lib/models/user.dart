enum UserType { registered, anonymous }

class User {
  final int? userId;
  final UserType userType;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool isEmailVerified;
  final DateTime registrationDate;
  final String? token;

  const User({
    this.userId,
    required this.userType,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.isEmailVerified,
    required this.registrationDate,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int?,
      userType: json['user_type'] == 'registered'
          ? UserType.registered
          : UserType.anonymous,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String,
      isEmailVerified: json['is_email_verified'] as bool,
      registrationDate: DateTime.parse(json['registration_date'] as String),
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_type': userType == UserType.registered ? 'registered' : 'anonymous',
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'is_email_verified': isEmailVerified,
      'registration_date': registrationDate.toIso8601String(),
      'token': token,
    };
  }

  User copyWith({
    int? userId,
    UserType? userType,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isEmailVerified,
    DateTime? registrationDate,
    String? token,
  }) {
    return User(
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      registrationDate: registrationDate ?? this.registrationDate,
      token: token ?? this.token,
    );
  }
}

class UserRegistrationRequest {
  final String userType;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool isEmailVerified;
  final DateTime registrationDate;

  const UserRegistrationRequest({
    required this.userType,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.isEmailVerified,
    required this.registrationDate,
  });

  factory UserRegistrationRequest.fromJson(Map<String, dynamic> json) {
    return UserRegistrationRequest(
      userType: json['user_type'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String,
      isEmailVerified: json['is_email_verified'] as bool,
      registrationDate: DateTime.parse(json['registration_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_type': userType,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'is_email_verified': isEmailVerified,
      'registration_date': registrationDate.toIso8601String(),
    };
  }
}

class UserRegistrationResponse {
  final bool success;
  final UserRegistrationData data;

  const UserRegistrationResponse({required this.success, required this.data});

  factory UserRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return UserRegistrationResponse(
      success: json['success'] as bool,
      data: UserRegistrationData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class UserRegistrationData {
  final int userId;
  final String token;

  const UserRegistrationData({required this.userId, required this.token});

  factory UserRegistrationData.fromJson(Map<String, dynamic> json) {
    return UserRegistrationData(
      userId: json['user_id'] as int,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'token': token};
  }
}
