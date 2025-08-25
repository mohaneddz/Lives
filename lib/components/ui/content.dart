import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lives/pages/home.dart';
import 'package:lives/pages/account.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_state.dart';

class Content extends StatelessWidget {
  const Content({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        switch (state.selectedItem) {
          case NavigationItem.home:
            return const MapPage();
          case NavigationItem.account:
            return const AccountScreen();
        }
      },
    );
  }
}
