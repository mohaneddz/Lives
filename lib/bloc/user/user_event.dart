import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUser extends UserEvent {}

class UpdateUserStatus extends UserEvent {
  final bool isOnline;

  const UpdateUserStatus({required this.isOnline});

  @override
  List<Object> get props => [isOnline];
}
