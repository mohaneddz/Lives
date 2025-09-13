enum ContributorType { individual, association }

enum VerificationStatus { pending, verified, rejected }

class Contributor {
  final int? contributorId;
  final int userId;
  final ContributorType contributorType;
  final VerificationStatus verificationStatus;
  final bool verified;
  final String email;
  final String? firstName;
  final String? lastName;
  final String phoneNumber;
  final String? idCardPicture;
  final String? selfiePicture;
  final String? organizationName;
  final String? organizationAddress;
  final String? registrationCertificatePicture;

  const Contributor({
    this.contributorId,
    required this.userId,
    required this.contributorType,
    required this.verificationStatus,
    required this.verified,
    required this.email,
    this.firstName,
    this.lastName,
    required this.phoneNumber,
    this.idCardPicture,
    this.selfiePicture,
    this.organizationName,
    this.organizationAddress,
    this.registrationCertificatePicture,
  });

  factory Contributor.fromJson(Map<String, dynamic> json) {
    return Contributor(
      contributorId: json['contributor_id'] as int?,
      userId: json['user_id'] as int,
      contributorType: json['contributor_type'] == 'individual'
          ? ContributorType.individual
          : ContributorType.association,
      verificationStatus: _parseVerificationStatus(
        json['verification_status'] as String,
      ),
      verified: json['verified'] as bool,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String,
      idCardPicture: json['id_card_picture'] as String?,
      selfiePicture: json['selfie_picture'] as String?,
      organizationName: json['organization_name'] as String?,
      organizationAddress: json['organization_address'] as String?,
      registrationCertificatePicture:
          json['registration_certificate_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contributor_id': contributorId,
      'user_id': userId,
      'contributor_type': contributorType == ContributorType.individual
          ? 'individual'
          : 'association',
      'verification_status': _verificationStatusToString(verificationStatus),
      'verified': verified,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'id_card_picture': idCardPicture,
      'selfie_picture': selfiePicture,
      'organization_name': organizationName,
      'organization_address': organizationAddress,
      'registration_certificate_picture': registrationCertificatePicture,
    };
  }

  static VerificationStatus _parseVerificationStatus(String status) {
    switch (status) {
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }

  static String _verificationStatusToString(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.verified:
        return 'verified';
      case VerificationStatus.rejected:
        return 'rejected';
    }
  }

  Contributor copyWith({
    int? contributorId,
    int? userId,
    ContributorType? contributorType,
    VerificationStatus? verificationStatus,
    bool? verified,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? idCardPicture,
    String? selfiePicture,
    String? organizationName,
    String? organizationAddress,
    String? registrationCertificatePicture,
  }) {
    return Contributor(
      contributorId: contributorId ?? this.contributorId,
      userId: userId ?? this.userId,
      contributorType: contributorType ?? this.contributorType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verified: verified ?? this.verified,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idCardPicture: idCardPicture ?? this.idCardPicture,
      selfiePicture: selfiePicture ?? this.selfiePicture,
      organizationName: organizationName ?? this.organizationName,
      organizationAddress: organizationAddress ?? this.organizationAddress,
      registrationCertificatePicture:
          registrationCertificatePicture ?? this.registrationCertificatePicture,
    );
  }
}

class ContributorRegistrationRequest {
  final int userId;
  final String contributorType;
  final String verificationStatus;
  final bool verified;
  final String email;
  final String? firstName;
  final String? lastName;
  final String phoneNumber;
  final String? idCardPicture;
  final String? selfiePicture;
  final String? organizationName;
  final String? organizationAddress;
  final String? registrationCertificatePicture;

  const ContributorRegistrationRequest({
    required this.userId,
    required this.contributorType,
    required this.verificationStatus,
    required this.verified,
    required this.email,
    this.firstName,
    this.lastName,
    required this.phoneNumber,
    this.idCardPicture,
    this.selfiePicture,
    this.organizationName,
    this.organizationAddress,
    this.registrationCertificatePicture,
  });

  factory ContributorRegistrationRequest.fromJson(Map<String, dynamic> json) {
    return ContributorRegistrationRequest(
      userId: json['user_id'] as int,
      contributorType: json['contributor_type'] as String,
      verificationStatus: json['verification_status'] as String,
      verified: json['verified'] as bool,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String,
      idCardPicture: json['id_card_picture'] as String?,
      selfiePicture: json['selfie_picture'] as String?,
      organizationName: json['organization_name'] as String?,
      organizationAddress: json['organization_address'] as String?,
      registrationCertificatePicture:
          json['registration_certificate_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'contributor_type': contributorType,
      'verification_status': verificationStatus,
      'verified': verified,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'id_card_picture': idCardPicture,
      'selfie_picture': selfiePicture,
      'organization_name': organizationName,
      'organization_address': organizationAddress,
      'registration_certificate_picture': registrationCertificatePicture,
    };
  }
}
