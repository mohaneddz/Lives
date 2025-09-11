import 'package:equatable/equatable.dart';

enum UserStatus { loading, loaded, error }

class UserState extends Equatable {
  final UserStatus status;
  final String name;
  final String email;
  final bool isOnline;
  final String? errorMessage;

  const UserState({
    required this.status,
    required this.name,
    required this.email,
    required this.isOnline,
    this.errorMessage,
  });

  const UserState.initial()
      : status = UserStatus.loading,
        name = '',
        email = '',
        isOnline = false,
        errorMessage = null;

  @override
  List<Object?> get props => [status, name, email, isOnline, errorMessage];

  UserState copyWith({
    UserStatus? status,
    String? name,
    String? email,
    bool? isOnline,
    String? errorMessage,
  }) {
    return UserState(
      status: status ?? this.status,
      name: name ?? this.name,
      email: email ?? this.email,
      isOnline: isOnline ?? this.isOnline,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
