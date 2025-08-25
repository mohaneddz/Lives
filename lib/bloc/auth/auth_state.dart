import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../models/contributor.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  authenticated,
  error,
  userTypeSelection,
  contributorTypeSelection,
  userRegistrationForm,
  contributorRegistrationForm,
  emailVerification,
  userRegistered,
  contributorRegistered,
  emailVerified,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final Contributor? contributor;
  final String? errorMessage;
  final String? accessToken;
  final String? refreshToken;
  final String? token; // Legacy compatibility
  final bool isContributor;
  final String? selectedContributorType;
  final bool isEmailVerified;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.contributor,
    this.errorMessage,
    this.accessToken,
    this.refreshToken,
    this.token,
    this.isContributor = false,
    this.selectedContributorType,
    this.isEmailVerified = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Contributor? contributor,
    String? errorMessage,
    String? accessToken,
    String? refreshToken,
    String? token,
    bool? isContributor,
    String? selectedContributorType,
    bool? isEmailVerified,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      contributor: contributor ?? this.contributor,
      errorMessage: errorMessage,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      token: token ?? this.token,
      isContributor: isContributor ?? this.isContributor,
      selectedContributorType:
          selectedContributorType ?? this.selectedContributorType,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  AuthState clearError() {
    return copyWith(errorMessage: null);
  }

  AuthState reset() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  // Convenience getters
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null && accessToken != null;

  bool get hasError => status == AuthStatus.error && errorMessage != null;

  bool get isLoading => status == AuthStatus.loading;

  String get displayName {
    if (user != null) {
      return '${user!.firstName} ${user!.lastName}';
    }
    return 'Unknown User';
  }

  @override
  List<Object?> get props => [
    status,
    user,
    contributor,
    errorMessage,
    accessToken,
    refreshToken,
    token,
    isContributor,
    selectedContributorType,
    isEmailVerified,
  ];

  @override
  String toString() {
    return '''AuthState {
      status: $status,
      user: $user,
      contributor: $contributor,
      errorMessage: $errorMessage,
      accessToken: ${accessToken != null ? 'present' : 'null'},
      refreshToken: ${refreshToken != null ? 'present' : 'null'},
    }''';
  }
}
