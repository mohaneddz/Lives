import 'package:flutter/material.dart';
import '../components/ui/content.dart';
import '../components/ui/navigation.dart';

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(drawer: const MySideNavigation(), body: const Content());
  }
}
