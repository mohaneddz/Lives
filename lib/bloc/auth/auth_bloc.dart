import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../models/contributor.dart';
import '../../services/auth_service.dart';
import '../../services/token_storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(const AuthState()) {
    // Register event handlers
    on<LoadAuthState>(_onLoadAuthState);
    on<RegisterUser>(_onRegisterUser);
    on<RegisterContributor>(_onRegisterContributor);
    on<LoginUser>(_onLoginUser);
    on<LoginContributor>(_onLoginContributor);
    on<Logout>(_onLogout);

    // UI Navigation events
    on<SelectUserType>(_onSelectUserType);
    on<SelectContributorType>(_onSelectContributorType);
    on<GoBackToPreviousStep>(_onGoBackToPreviousStep);

    // Legacy events for backwards compatibility
    on<RegisterIndividualContributor>(_onRegisterIndividualContributor);
    on<RegisterAssociationContributor>(_onRegisterAssociationContributor);
    on<ResetAuthState>(_onResetAuthState);
  }

  Future<void> _onLoadAuthState(
    LoadAuthState event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final isAuthenticated = await _authService.isAuthenticated();

      if (isAuthenticated) {
        final user = await _authService.getCurrentUser();
        final contributor = await _authService.getCurrentContributor();
        final accessToken = await TokenStorageService.getAccessToken();

        if (user != null) {
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              contributor: contributor,
              accessToken: accessToken,
              token: accessToken, // Set token field for UserBloc compatibility
            ),
          );
        } else {
          emit(state.copyWith(status: AuthStatus.userTypeSelection));
        }
      } else {
        emit(state.copyWith(status: AuthStatus.userTypeSelection));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.userTypeSelection,
          errorMessage: 'Failed to load authentication state',
        ),
      );
    }
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final request = UserRegistrationRequest(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
        preferredLanguage: event.preferredLanguage,
      );

      final response = await _authService.registerUser(request);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data.user,
          accessToken: response.data.accessToken,
          refreshToken: response.data.refreshToken,
          token: response
              .data
              .accessToken, // Set token field for UserBloc compatibility
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onRegisterContributor(
    RegisterContributor event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final request = ContributorRegistrationRequest(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        contributorType: event.contributorType,
        motivation: event.motivation,
      );

      final response = await _authService.registerContributor(request);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data.user,
          contributor: response.data.contributor,
          accessToken: response.data.accessToken,
          refreshToken: response.data.refreshToken,
          token: response
              .data
              .accessToken, // Set token field for UserBloc compatibility
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoginUser(LoginUser event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final request = UserLoginRequest(
        email: event.email,
        password: event.password,
      );

      final response = await _authService.loginUser(request);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data.user,
          accessToken: response.data.accessToken,
          refreshToken: response.data.refreshToken,
          token: response
              .data
              .accessToken, // Set token field for UserBloc compatibility
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoginContributor(
    LoginContributor event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final request = ContributorLoginRequest(
        email: event.email,
        password: event.password,
      );

      final response = await _authService.loginContributor(request);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data.user,
          contributor: response.data.contributor,
          accessToken: response.data.accessToken,
          refreshToken: response.data.refreshToken,
          token: response
              .data
              .accessToken, // Set token field for UserBloc compatibility
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _authService.logout();
      emit(state.reset());
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Logout failed: ${e.toString()}',
        ),
      );
    }
  }

  // Legacy handlers for backwards compatibility
  Future<void> _onRegisterIndividualContributor(
    RegisterIndividualContributor event,
    Emitter<AuthState> emit,
  ) async {
    // Convert legacy event to new event format
    final newEvent = RegisterContributor(
      email: event.email,
      password: '', // This would need to be collected from UI
      firstName: event.firstName,
      lastName: event.lastName,
      contributorType: 'individual',
      motivation: '', // Default or collect from UI
    );

    await _onRegisterContributor(newEvent, emit);
  }

  Future<void> _onRegisterAssociationContributor(
    RegisterAssociationContributor event,
    Emitter<AuthState> emit,
  ) async {
    // Convert legacy event to new event format
    final newEvent = RegisterContributor(
      email: event.email,
      password: '', // This would need to be collected from UI
      firstName: event.organizationName,
      lastName: '', // Associations may not have lastName
      contributorType: 'association',
      motivation: '', // Default or collect from UI
    );

    await _onRegisterContributor(newEvent, emit);
  }

  Future<void> _onResetAuthState(
    ResetAuthState event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.userTypeSelection));
  }

  void _onSelectUserType(SelectUserType event, Emitter<AuthState> emit) {
    if (event.isContributor) {
      emit(
        state.copyWith(
          status: AuthStatus.contributorTypeSelection,
          isContributor: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.userRegistrationForm,
          isContributor: false,
        ),
      );
    }
  }

  void _onSelectContributorType(
    SelectContributorType event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        status: AuthStatus.contributorRegistrationForm,
        selectedContributorType: event.contributorType
            .toString()
            .split('.')
            .last,
      ),
    );
  }

  void _onGoBackToPreviousStep(
    GoBackToPreviousStep event,
    Emitter<AuthState> emit,
  ) {
    switch (state.status) {
      case AuthStatus.contributorTypeSelection:
        emit(
          state.copyWith(
            status: AuthStatus.userTypeSelection,
            isContributor: false,
          ),
        );
        break;
      case AuthStatus.userRegistrationForm:
        emit(state.copyWith(status: AuthStatus.userTypeSelection));
        break;
      case AuthStatus.contributorRegistrationForm:
        emit(state.copyWith(status: AuthStatus.contributorTypeSelection));
        break;
      default:
        emit(state.copyWith(status: AuthStatus.userTypeSelection));
        break;
    }
  }
}
