import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import 'search_bar.dart';
import 'filter_button.dart';

class TopBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  const TopBar({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              // Menu Button
              IconButton(
                onPressed: onMenuTap,
                icon: const Icon(
                  Icons.menu,
                  color: AppColors.onSurface,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              
              const SizedBox(width: 16),
              
              // Title Section
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lives',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Humanitarian Aid',
                      style: TextStyle(
                        color: AppColors.neutral600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Notification Button
              IconButton(
                onPressed: onNotificationTap,
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.onSurface,
                    ),
                    // Notification dot (optional)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Search and Filter Row
          const Row(
            children: [
              Expanded(
                child: CustomSearchBar(),
              ),
              SizedBox(width: 12),
              FilterButton(),
            ],
          ),
        ],
      ),
    );
  }
}