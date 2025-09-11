import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(const UserState.initial()) {
    on<LoadUser>(_onLoadUser);
    on<UpdateUserStatus>(_onUpdateUserStatus);
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.loading));
    
    try {
      // Simulate loading user data
      await Future.delayed(const Duration(seconds: 2));
      
      emit(state.copyWith(
        status: UserStatus.loaded,
        name: 'John Doe',
        email: 'john.doe@example.com',
        isOnline: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserStatus.error,
        errorMessage: 'Failed to load user data',
      ));
    }
  }

  void _onUpdateUserStatus(UpdateUserStatus event, Emitter<UserState> emit) {
    emit(state.copyWith(isOnline: event.isOnline));
  }
}
