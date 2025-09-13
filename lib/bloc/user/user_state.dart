import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../models/contributor.dart';

enum UserStatus { loading, loaded, error, unauthenticated }

class UserState extends Equatable {
  final UserStatus status;
  final String name;
  final String email;
  final String? phoneNumber;
  final bool isOnline;
  final bool isAuthenticated;
  final bool isEmailVerified;
  final String? errorMessage;
  final User? user;
  final Contributor? contributor;
  final String? token;

  const UserState({
    required this.status,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.isOnline,
    required this.isAuthenticated,
    required this.isEmailVerified,
    this.errorMessage,
    this.user,
    this.contributor,
    this.token,
  });

  const UserState.initial()
    : status = UserStatus.unauthenticated,
      name = 'Guest User',
      email = '',
      phoneNumber = null,
      isOnline = false,
      isAuthenticated = false,
      isEmailVerified = false,
      errorMessage = null,
      user = null,
      contributor = null,
      token = null;

  @override
  List<Object?> get props => [
    status,
    name,
    email,
    phoneNumber,
    isOnline,
    isAuthenticated,
    isEmailVerified,
    errorMessage,
    user,
    contributor,
    token,
  ];

  UserState copyWith({
    UserStatus? status,
    String? name,
    String? email,
    String? phoneNumber,
    bool? isOnline,
    bool? isAuthenticated,
    bool? isEmailVerified,
    String? errorMessage,
    User? user,
    Contributor? contributor,
    String? token,
  }) {
    return UserState(
      status: status ?? this.status,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isOnline: isOnline ?? this.isOnline,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      contributor: contributor ?? this.contributor,
      token: token ?? this.token,
    );
  }

  factory UserState.authenticated(
    User user, {
    String? token,
    Contributor? contributor,
  }) {
    return UserState(
      status: UserStatus.loaded,
      name: ' '.trim(),
      email: user.email,
      phoneNumber: user.phoneNumber,
      isOnline: true,
      isAuthenticated: true,
      isEmailVerified: user.isEmailVerified,
      user: user,
      contributor: contributor,
      token: token,
    );
  }

  factory UserState.unauthenticated() {
    return const UserState.initial();
  }
}
