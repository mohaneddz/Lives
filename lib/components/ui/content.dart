import 'package:flutter/material.dart';

import 'package:lives/pages/home.dart';
import 'package:lives/pages/account.dart';

class Content extends StatelessWidget {
  final int index;
  const Content({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const AccountScreen();
      default:
        return const HomeScreen();
    }
  }
}
