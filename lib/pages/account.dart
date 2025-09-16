import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../services/auth_service.dart';
import '../widgets/user_type_selection.dart';
import '../widgets/contributor_type_selection.dart';
import '../widgets/user_registration_form.dart';
import '../widgets/individual_contributor_form.dart';
import '../widgets/association_contributor_form.dart';
import '../widgets/email_verification.dart';
import '../widgets/auth_status.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(authService: AuthService())..add(const LoadAuthState()),
      child: const AccountScreenContent(),
    );
  }
}

class AccountScreenContent extends StatelessWidget {
  const AccountScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // When authentication completes successfully, update the UserBloc
        if (state.status == AuthStatus.authenticated &&
            state.user != null &&
            context.mounted) {
          context.read<UserBloc>().add(
            AuthenticateUser(
              user: state.user!,
              token: state.token,
              contributor: state.contributor,
            ),
          );
        }

        // When user logs out or resets auth, clear UserBloc
        if (state.status == AuthStatus.initial ||
            (state.status == AuthStatus.userTypeSelection &&
                state.user == null)) {
          context.read<UserBloc>().add(LogoutUser());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Show different screens based on authentication state
          switch (state.status) {
            case AuthStatus.initial:
            case AuthStatus.loading:
              return _buildLoadingScreen(context);

            case AuthStatus.unauthenticated:
            case AuthStatus.userTypeSelection:
              return const UserTypeSelectionWidget();

            case AuthStatus.contributorTypeSelection:
              return const ContributorTypeSelectionWidget();

            case AuthStatus.userRegistrationForm:
              return const UserRegistrationForm();

            case AuthStatus.contributorRegistrationForm:
              if (state.selectedContributorType == 'individual') {
                return const IndividualContributorForm();
              } else {
                return const AssociationContributorForm();
              }

            case AuthStatus.emailVerification:
              return const EmailVerificationWidget();

            case AuthStatus.userRegistered:
            case AuthStatus.contributorRegistered:
            case AuthStatus.emailVerified:
            case AuthStatus.authenticated:
              return const AuthStatusWidget();

            case AuthStatus.error:
              return _buildErrorScreen(context, state);
          }
        },
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: MediaQuery.of(context).size.width,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, AuthState state) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'An unknown error occurred',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const ResetAuthState());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Try Again'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
