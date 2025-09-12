import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc()
    : super(const NavigationState(selectedItem: NavigationItem.home)) {
    on<NavigateToHome>(_onNavigateToHome);
    on<NavigateToAccount>(_onNavigateToAccount);
  }

  void _onNavigateToHome(NavigateToHome event, Emitter<NavigationState> emit) {
    emit(state.copyWith(selectedItem: NavigationItem.home));
  }

  void _onNavigateToAccount(
    NavigateToAccount event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(selectedItem: NavigationItem.account));
  }
}
