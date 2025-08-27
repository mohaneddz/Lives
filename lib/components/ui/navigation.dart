import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MyNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Account'),
      ],
    );
  }
}
