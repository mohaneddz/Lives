import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../bloc/auth/auth.dart';

class AuthStatusWidget extends StatelessWidget {
  const AuthStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),

                      // Success Icon
                      Container(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.checkCircle,
                            size: 64,
                            color: Colors.green,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        _getTitle(state),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        _getDescription(state),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // User Info Card
                      if (state.user != null)
                        _buildUserInfoCard(context, state),

                      // Contributor Info Card
                      if (state.contributor != null)
                        _buildContributorInfoCard(context, state),

                      const Spacer(),

                      // Action Buttons
                      if (state.status == AuthStatus.authenticated)
                        _buildAuthenticatedButtons(context)
                      else if (state.status == AuthStatus.contributorRegistered)
                        _buildContributorButtons(context)
                      else if (state.status == AuthStatus.emailVerified &&
                          state.isContributor)
                        _buildEmailVerifiedButtons(context),

                      const SizedBox(height: 24), // Extra padding at bottom
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getTitle(AuthState state) {
    switch (state.status) {
      case AuthStatus.emailVerified:
        return 'Email Verified!';
      case AuthStatus.contributorRegistered:
        return 'Contributor Registered!';
      case AuthStatus.authenticated:
        return 'Welcome!';
      default:
        return 'Success!';
    }
  }

  String _getDescription(AuthState state) {
    switch (state.status) {
      case AuthStatus.emailVerified:
        if (state.isContributor) {
          return 'Your email has been verified. You can now proceed with contributor registration.';
        }
        return 'Your email has been verified and your account is now active.';
      case AuthStatus.contributorRegistered:
        return 'Your contributor application has been submitted successfully. It will remain in pending status until verified by our team.';
      case AuthStatus.authenticated:
        return 'Your account is now active and ready to use. Welcome to Lives App!';
      default:
        return 'Your registration process has been completed.';
    }
  }

  Widget _buildUserInfoCard(BuildContext context, AuthState state) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.user,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'User Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Name',
              '${state.user!.firstName} ${state.user!.lastName}',
            ),
            _buildInfoRow('Email', state.user!.email),
            _buildInfoRow('Phone', state.user!.phoneNumber ?? 'Not provided'),
            _buildInfoRow(
              'Status',
              state.isEmailVerified ? 'Verified' : 'Pending Verification',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributorInfoCard(BuildContext context, AuthState state) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  state.contributor!.contributorType == 'individual'
                      ? LucideIcons.user
                      : LucideIcons.building,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contributor Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Type',
              state.contributor!.contributorType == 'individual'
                  ? 'Individual'
                  : 'Association',
            ),
            if (state.contributor!.organizationName != null)
              _buildInfoRow(
                'Organization',
                state.contributor!.organizationName!,
              ),
            if (state.contributor!.firstName != null)
              _buildInfoRow(
                'Name',
                '${state.contributor!.firstName} ${state.contributor!.lastName}',
              ),
            _buildInfoRow('Email', state.contributor!.email ?? 'Not provided'),
            _buildInfoRow(
              'Phone',
              state.contributor!.phoneNumber ?? 'Not provided',
            ),
            _buildInfoRow('Verification Status', 'Pending'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Navigate to home or close the auth flow
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continue to App',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            // Show confirmation dialog before logout
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<AuthBloc>().add(const Logout());
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                );
              },
            );
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey[400]!),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Logout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContributorButtons(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.clock, color: Colors.orange[600], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your contributor application is under review. You\'ll be notified once it\'s approved.',
                  style: TextStyle(color: Colors.orange[700], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continue to App',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailVerifiedButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            context.read<AuthBloc>().add(
              const SelectUserType(isContributor: true),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continue with Contributor Registration',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Skip for now'),
        ),
      ],
    );
  }
}
