// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/map/map_bloc.dart';
import 'bloc/navigation/navigation_bloc.dart';
import 'bloc/user/user_bloc.dart';
import 'bloc/user/user_event.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'services/auth_service.dart';
import 'pages/main_app.dart';
import 'styles/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lives - Humanitarian Aid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
        ),
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => MapBloc()),
          BlocProvider(create: (context) => NavigationBloc()),
          BlocProvider(create: (context) => UserBloc()..add(LoadUser())),
          BlocProvider(
            create: (context) =>
                AuthBloc(authService: AuthService())
                  ..add(const LoadAuthState()),
          ),
        ],
        child: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainAppScreen();
  }
}
