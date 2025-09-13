import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../models/contributor.dart';
import '../../models/verification.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(const AuthState()) {
    // Register event handlers
    on<LoadAuthState>(_onLoadAuthState);
    on<SelectUserType>(_onSelectUserType);
    on<SelectContributorType>(_onSelectContributorType);
    on<RegisterUser>(_onRegisterUser);
    on<RegisterIndividualContributor>(_onRegisterIndividualContributor);
    on<RegisterAssociationContributor>(_onRegisterAssociationContributor);
    on<VerifyEmail>(_onVerifyEmail);
    on<ResendVerificationEmail>(_onResendVerificationEmail);
    on<ResetAuthState>(_onResetAuthState);
    on<GoBackToPreviousStep>(_onGoBackToPreviousStep);
    on<Logout>(_onLogout);
  }

  void _onLoadAuthState(LoadAuthState event, Emitter<AuthState> emit) {
    // Load from shared preferences if needed
    // For now, show user type selection
    emit(state.copyWith(status: AuthStatus.userTypeSelection));
  }

  void _onSelectUserType(SelectUserType event, Emitter<AuthState> emit) {
    if (event.isContributor) {
      emit(
        state.copyWith(
          isContributor: true,
          status: AuthStatus.contributorTypeSelection,
          errorMessage: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isContributor: false,
          status: AuthStatus.userRegistrationForm,
          errorMessage: null,
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
        selectedContributorType: event.contributorType,
        status: AuthStatus.contributorRegistrationForm,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final request = AuthService.createUserRegistrationRequest(
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
      );

      final response = await _authService.registerUser(request);

      if (response.success) {
        final user = User(
          userId: response.data.userId,
          userType: UserType.registered,
          email: event.email,
          firstName: event.firstName,
          lastName: event.lastName,
          phoneNumber: event.phoneNumber,
          isEmailVerified: false,
          registrationDate: DateTime.now(),
          token: response.data.token,
        );

        emit(
          state.copyWith(
            status: AuthStatus.emailVerification,
            user: user,
            token: response.data.token,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Registration failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString().replaceAll('AuthException: ', ''),
        ),
      );
    }
  }

  Future<void> _onRegisterIndividualContributor(
    RegisterIndividualContributor event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user?.userId == null) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'User must be registered first',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final request = AuthService.createIndividualContributorRequest(
        userId: state.user!.userId!,
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
        idCardPicture: event.idCardPicture,
        selfiePicture: event.selfiePicture,
      );

      final response = await _authService.registerContributor(request);

      if (response.success) {
        final contributor = Contributor(
          userId: state.user!.userId!,
          contributorType: ContributorType.individual,
          verificationStatus: VerificationStatus.pending,
          verified: false,
          email: event.email,
          firstName: event.firstName,
          lastName: event.lastName,
          phoneNumber: event.phoneNumber,
          idCardPicture: event.idCardPicture,
          selfiePicture: event.selfiePicture,
        );

        emit(
          state.copyWith(
            status: AuthStatus.contributorRegistered,
            contributor: contributor,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Contributor registration failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString().replaceAll('AuthException: ', ''),
        ),
      );
    }
  }

  Future<void> _onRegisterAssociationContributor(
    RegisterAssociationContributor event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user?.userId == null) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'User must be registered first',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final request = AuthService.createAssociationContributorRequest(
        userId: state.user!.userId!,
        email: event.email,
        phoneNumber: event.phoneNumber,
        organizationName: event.organizationName,
        organizationAddress: event.organizationAddress,
        registrationCertificatePicture: event.registrationCertificatePicture,
      );

      final response = await _authService.registerContributor(request);

      if (response.success) {
        final contributor = Contributor(
          userId: state.user!.userId!,
          contributorType: ContributorType.association,
          verificationStatus: VerificationStatus.pending,
          verified: false,
          email: event.email,
          phoneNumber: event.phoneNumber,
          organizationName: event.organizationName,
          organizationAddress: event.organizationAddress,
          registrationCertificatePicture: event.registrationCertificatePicture,
        );

        emit(
          state.copyWith(
            status: AuthStatus.contributorRegistered,
            contributor: contributor,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Association registration failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString().replaceAll('AuthException: ', ''),
        ),
      );
    }
  }

  Future<void> _onVerifyEmail(
    VerifyEmail event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user?.userId == null) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'No user found for verification',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final request = EmailVerificationRequest(
        userId: state.user!.userId!,
        verificationCode: event.verificationCode,
      );

      final response = await _authService.verifyEmail(request);

      if (response.success && response.data.validated) {
        final updatedUser = state.user!.copyWith(isEmailVerified: true);

        final newStatus = state.isContributor
            ? AuthStatus.contributorTypeSelection
            : AuthStatus.authenticated;

        emit(
          state.copyWith(
            status: newStatus,
            user: updatedUser,
            isEmailVerified: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: response.data.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString().replaceAll('AuthException: ', ''),
        ),
      );
    }
  }

  Future<void> _onResendVerificationEmail(
    ResendVerificationEmail event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user?.userId == null) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'No user found for resending email',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final request = ResendVerificationRequest(userId: state.user!.userId!);

      await _authService.resendVerificationEmail(request);

      emit(
        state.copyWith(
          status: AuthStatus.emailVerification,
          errorMessage: 'New verification code sent to your email',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString().replaceAll('AuthException: ', ''),
        ),
      );
    }
  }

  void _onResetAuthState(ResetAuthState event, Emitter<AuthState> emit) {
    emit(const AuthState(status: AuthStatus.userTypeSelection));
  }

  void _onGoBackToPreviousStep(
    GoBackToPreviousStep event,
    Emitter<AuthState> emit,
  ) {
    switch (state.status) {
      case AuthStatus.userRegistrationForm:
      case AuthStatus.contributorTypeSelection:
        emit(
          state.copyWith(
            status: AuthStatus.userTypeSelection,
            isContributor: false,
            selectedContributorType: null,
            errorMessage: null,
          ),
        );
        break;
      case AuthStatus.contributorRegistrationForm:
        emit(
          state.copyWith(
            status: AuthStatus.contributorTypeSelection,
            selectedContributorType: null,
            errorMessage: null,
          ),
        );
        break;
      case AuthStatus.emailVerification:
        if (state.isContributor) {
          emit(
            state.copyWith(
              status: AuthStatus.contributorTypeSelection,
              errorMessage: null,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.userRegistrationForm,
              errorMessage: null,
            ),
          );
        }
        break;
      default:
        // For other states, go to user type selection
        emit(
          state.copyWith(
            status: AuthStatus.userTypeSelection,
            errorMessage: null,
          ),
        );
    }
  }

  void _onLogout(Logout event, Emitter<AuthState> emit) {
    emit(const AuthState());
  }
}
