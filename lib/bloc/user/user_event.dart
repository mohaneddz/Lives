import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../models/contributor.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUser extends UserEvent {}

class UpdateUserStatus extends UserEvent {
  final bool isOnline;

  const UpdateUserStatus({required this.isOnline});

  @override
  List<Object?> get props => [isOnline];
}

class AuthenticateUser extends UserEvent {
  final User user;
  final String? token;
  final Contributor? contributor;

  const AuthenticateUser({required this.user, this.token, this.contributor});

  @override
  List<Object?> get props => [user, token, contributor];
}

class LogoutUser extends UserEvent {}

class UpdateUserData extends UserEvent {
  final User user;

  const UpdateUserData({required this.user});

  @override
  List<Object?> get props => [user];
}

class UpdateContributorData extends UserEvent {
  final Contributor contributor;

  const UpdateContributorData({required this.contributor});

  @override
  List<Object?> get props => [contributor];
}
