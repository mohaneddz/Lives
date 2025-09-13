import 'package:equatable/equatable.dart';
import '../../models/contributor.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// User registration events
class RegisterUser extends AuthEvent {
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const RegisterUser({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [email, firstName, lastName, phoneNumber];
}

// Contributor registration events
class RegisterIndividualContributor extends AuthEvent {
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? idCardPicture;
  final String? selfiePicture;

  const RegisterIndividualContributor({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.idCardPicture,
    this.selfiePicture,
  });

  @override
  List<Object?> get props => [
    email,
    firstName,
    lastName,
    phoneNumber,
    idCardPicture,
    selfiePicture,
  ];
}

class RegisterAssociationContributor extends AuthEvent {
  final String email;
  final String phoneNumber;
  final String organizationName;
  final String organizationAddress;
  final String? registrationCertificatePicture;

  const RegisterAssociationContributor({
    required this.email,
    required this.phoneNumber,
    required this.organizationName,
    required this.organizationAddress,
    this.registrationCertificatePicture,
  });

  @override
  List<Object?> get props => [
    email,
    phoneNumber,
    organizationName,
    organizationAddress,
    registrationCertificatePicture,
  ];
}

// Email verification events
class VerifyEmail extends AuthEvent {
  final String verificationCode;

  const VerifyEmail({required this.verificationCode});

  @override
  List<Object> get props => [verificationCode];
}

class ResendVerificationEmail extends AuthEvent {
  const ResendVerificationEmail();
}

// Navigation and reset events
class ResetAuthState extends AuthEvent {
  const ResetAuthState();
}

class GoBackToPreviousStep extends AuthEvent {
  const GoBackToPreviousStep();
}

class SelectUserType extends AuthEvent {
  final bool isContributor;

  const SelectUserType({required this.isContributor});

  @override
  List<Object> get props => [isContributor];
}

class SelectContributorType extends AuthEvent {
  final ContributorType contributorType;

  const SelectContributorType({required this.contributorType});

  @override
  List<Object> get props => [contributorType];
}

// Load existing authentication state
class LoadAuthState extends AuthEvent {
  const LoadAuthState();
}

class Logout extends AuthEvent {
  const Logout();
}
