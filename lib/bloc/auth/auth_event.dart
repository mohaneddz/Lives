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
  final String password;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String preferredLanguage;

  const RegisterUser({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.preferredLanguage = 'en',
  });

  @override
  List<Object> get props => [
    email,
    password,
    firstName,
    lastName,
    phoneNumber,
    preferredLanguage,
  ];
}

// User login events
class LoginUser extends AuthEvent {
  final String email;
  final String password;

  const LoginUser({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

// Contributor registration events
class RegisterContributor extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String contributorType;
  final String motivation;

  const RegisterContributor({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.contributorType,
    required this.motivation,
  });

  @override
  List<Object> get props => [
    email,
    password,
    firstName,
    lastName,
    contributorType,
    motivation,
  ];
}

// Contributor login events
class LoginContributor extends AuthEvent {
  final String email;
  final String password;

  const LoginContributor({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
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

// Legacy events for Individual Contributors
class RegisterIndividualContributor extends AuthEvent {
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String idCardPicture;
  final String selfiePicture;

  const RegisterIndividualContributor({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.idCardPicture,
    required this.selfiePicture,
  });

  @override
  List<Object> get props => [
    email,
    firstName,
    lastName,
    phoneNumber,
    idCardPicture,
    selfiePicture,
  ];
}

// Legacy events for Association Contributors
class RegisterAssociationContributor extends AuthEvent {
  final String email;
  final String phoneNumber;
  final String organizationName;
  final String organizationAddress;
  final String registrationCertificatePicture;

  const RegisterAssociationContributor({
    required this.email,
    required this.phoneNumber,
    required this.organizationName,
    required this.organizationAddress,
    required this.registrationCertificatePicture,
  });

  @override
  List<Object> get props => [
    email,
    phoneNumber,
    organizationName,
    organizationAddress,
    registrationCertificatePicture,
  ];
}
