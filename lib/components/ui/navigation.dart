import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';
import '../../bloc/navigation/navigation_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';

class MySideNavigation extends StatelessWidget {
  const MySideNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40), // Status bar padding
                Text(
                  'Lives App',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Life Management Hub',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, navState) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildNavigationItem(
                      context,
                      icon: LucideIcons.home,
                      title: 'Home',
                      isSelected: navState.selectedItem == NavigationItem.home,
                      onTap: () {
                        context.read<NavigationBloc>().add(NavigateToHome());
                        Navigator.of(context).pop();
                      },
                    ),
                    _buildNavigationItem(
                      context,
                      icon: LucideIcons.user,
                      title: 'Account',
                      isSelected:
                          navState.selectedItem == NavigationItem.account,
                      onTap: () {
                        context.read<NavigationBloc>().add(NavigateToAccount());
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // User Status Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                if (userState.status == UserStatus.loaded &&
                    userState.isAuthenticated) {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: userState.isEmailVerified
                            ? (userState.isOnline ? Colors.green : Colors.blue)
                            : Colors.orange,
                        child: Icon(
                          userState.isEmailVerified
                              ? LucideIcons.user
                              : LucideIcons.userX,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userState.name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (userState.email.isNotEmpty)
                              Text(
                                userState.email,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: userState.isEmailVerified
                                        ? (userState.isOnline
                                              ? Colors.green
                                              : Colors.blue)
                                        : Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  userState.isEmailVerified
                                      ? (userState.isOnline
                                            ? 'Online • Verified'
                                            : 'Offline • Verified')
                                      : 'Email not verified',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: userState.isEmailVerified
                                            ? (userState.isOnline
                                                  ? Colors.green
                                                  : Colors.blue)
                                            : Colors.orange,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else if (userState.status == UserStatus.loading) {
                  return const Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Loading...'),
                    ],
                  );
                } else if (userState.status == UserStatus.unauthenticated) {
                  return Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          LucideIcons.user,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userState.name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Not authenticated',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.red,
                        child: Icon(
                          LucideIcons.userX,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Error loading user'),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      onTap: onTap,
    );
  }
}
