import 'package:flutter/material.dart';
import 'package:lives/styles/style.dart';
// Components:
import 'package:lives/components/ui/content.dart';
import 'package:lives/components/ui/navigation.dart';
// import 'package:lives/utils/movement_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.defaultLightTheme,
      home: Scaffold(
        body: Content(index: _currentIndex),
        bottomNavigationBar: MyNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}
