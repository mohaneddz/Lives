class EmailVerificationRequest {
  final int userId;
  final String verificationCode;

  const EmailVerificationRequest({
    required this.userId,
    required this.verificationCode,
  });

  factory EmailVerificationRequest.fromJson(Map<String, dynamic> json) {
    return EmailVerificationRequest(
      userId: json['user_id'] as int,
      verificationCode: json['verification_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'verification_code': verificationCode};
  }
}

class EmailVerificationResponse {
  final bool success;
  final EmailVerificationData data;

  const EmailVerificationResponse({required this.success, required this.data});

  factory EmailVerificationResponse.fromJson(Map<String, dynamic> json) {
    return EmailVerificationResponse(
      success: json['success'] as bool,
      data: EmailVerificationData.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class EmailVerificationData {
  final bool validated;
  final String message;

  const EmailVerificationData({required this.validated, required this.message});

  factory EmailVerificationData.fromJson(Map<String, dynamic> json) {
    return EmailVerificationData(
      validated: json['validated'] as bool,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'validated': validated, 'message': message};
  }
}

class ResendVerificationRequest {
  final int userId;

  const ResendVerificationRequest({required this.userId});

  factory ResendVerificationRequest.fromJson(Map<String, dynamic> json) {
    return ResendVerificationRequest(userId: json['user_id'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId};
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => ApiResponse<T>(
    success: json['success'] as bool,
    data: json['data'] != null ? fromJsonT(json['data']) : null,
    message: json['message'] as String?,
    error: json['error'] as String?,
  );

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => {
    'success': success,
    'data': data != null ? toJsonT(data as T) : null,
    'message': message,
    'error': error,
  };
}
