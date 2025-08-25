import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(const UserState.initial()) {
    on<LoadUser>(_onLoadUser);
    on<UpdateUserStatus>(_onUpdateUserStatus);
    on<AuthenticateUser>(_onAuthenticateUser);
    on<LogoutUser>(_onLogoutUser);
    on<UpdateUserData>(_onUpdateUserData);
    on<UpdateContributorData>(_onUpdateContributorData);
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    // Only load user data if not already authenticated
    if (state.isAuthenticated) {
      return;
    }

    emit(state.copyWith(status: UserStatus.loading));

    try {
      // Check for any persisted user data/token here
      // For now, just emit unauthenticated state
      await Future.delayed(const Duration(milliseconds: 500));

      emit(UserState.unauthenticated());
    } catch (e) {
      emit(
        state.copyWith(
          status: UserStatus.error,
          errorMessage: 'Failed to load user data',
        ),
      );
    }
  }

  void _onUpdateUserStatus(UpdateUserStatus event, Emitter<UserState> emit) {
    emit(state.copyWith(isOnline: event.isOnline));
  }

  void _onAuthenticateUser(AuthenticateUser event, Emitter<UserState> emit) {
    // Create authenticated state from the user data
    emit(
      UserState.authenticated(
        event.user,
        token: event.token,
        contributor: event.contributor,
      ),
    );
  }

  void _onLogoutUser(LogoutUser event, Emitter<UserState> emit) {
    // Clear all user data and return to unauthenticated state
    emit(UserState.unauthenticated());
  }

  void _onUpdateUserData(UpdateUserData event, Emitter<UserState> emit) {
    if (!state.isAuthenticated || state.user == null) return;

    // Update the user data while preserving other state
    emit(
      state.copyWith(
        user: event.user,
        name: '${event.user.firstName} ${event.user.lastName}'.trim(),
        email: event.user.email,
        phoneNumber: event.user.phoneNumber,
        isEmailVerified: event.user.isEmailVerified,
      ),
    );
  }

  void _onUpdateContributorData(
    UpdateContributorData event,
    Emitter<UserState> emit,
  ) {
    if (!state.isAuthenticated) return;

    // Update contributor data
    emit(state.copyWith(contributor: event.contributor));
  }
}
