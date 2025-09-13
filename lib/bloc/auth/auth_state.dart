import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../models/contributor.dart';

enum AuthStatus {
  initial,
  loading,
  userTypeSelection,
  contributorTypeSelection,
  userRegistrationForm,
  contributorRegistrationForm,
  emailVerification,
  userRegistered,
  contributorRegistered,
  emailVerified,
  authenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final Contributor? contributor;
  final String? errorMessage;
  final bool isContributor;
  final ContributorType? selectedContributorType;
  final bool isEmailVerified;
  final String? token;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.contributor,
    this.errorMessage,
    this.isContributor = false,
    this.selectedContributorType,
    this.isEmailVerified = false,
    this.token,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Contributor? contributor,
    String? errorMessage,
    bool? isContributor,
    ContributorType? selectedContributorType,
    bool? isEmailVerified,
    String? token,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      contributor: contributor ?? this.contributor,
      errorMessage: errorMessage ?? this.errorMessage,
      isContributor: isContributor ?? this.isContributor,
      selectedContributorType:
          selectedContributorType ?? this.selectedContributorType,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      token: token ?? this.token,
    );
  }

  AuthState clearError() {
    return copyWith(errorMessage: null);
  }

  AuthState reset() {
    return const AuthState();
  }

  // Convenience getters
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null && isEmailVerified;

  bool get canProceedToNextStep =>
      status != AuthStatus.loading && status != AuthStatus.error;

  bool get hasError => status == AuthStatus.error && errorMessage != null;

  bool get isUserRegistered => user != null && user!.userId != null;

  bool get needsEmailVerification => isUserRegistered && !isEmailVerified;

  bool get isContributorFlow => isContributor;

  bool get needsContributorTypeSelection =>
      isContributor && selectedContributorType == null;

  String get displayName {
    if (user != null) {
      return '${user!.firstName} ${user!.lastName}';
    } else if (contributor != null && contributor!.organizationName != null) {
      return contributor!.organizationName!;
    } else if (contributor != null && contributor!.firstName != null) {
      return '${contributor!.firstName} ${contributor!.lastName}';
    }
    return 'Unknown User';
  }

  @override
  List<Object?> get props => [
    status,
    user,
    contributor,
    errorMessage,
    isContributor,
    selectedContributorType,
    isEmailVerified,
    token,
  ];

  @override
  String toString() {
    return '''AuthState {
      status: $status,
      user: $user,
      contributor: $contributor,
      errorMessage: $errorMessage,
      isContributor: $isContributor,
      selectedContributorType: $selectedContributorType,
      isEmailVerified: $isEmailVerified,
      token: $token,
    }''';
  }
}
