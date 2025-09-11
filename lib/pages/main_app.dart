import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/ui/content.dart';
import '../components/ui/navigation.dart';
import '../bloc/navigation/navigation_bloc.dart';
import '../bloc/navigation/navigation_state.dart';

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            switch (state.selectedItem) {
              case NavigationItem.home:
                return const Text('Home');
              case NavigationItem.account:
                return const Text('Account');
            }
          },
        ),
        elevation: 0,
      ),
      drawer: const MySideNavigation(),
      body: const Content(),
    );
  }
}
