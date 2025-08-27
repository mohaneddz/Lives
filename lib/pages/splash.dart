import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: MediaQuery.of(context).size.width, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
