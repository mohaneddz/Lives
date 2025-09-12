import 'package:equatable/equatable.dart';

enum NavigationItem { home, account }

class NavigationState extends Equatable {
  final NavigationItem selectedItem;

  const NavigationState({required this.selectedItem});

  @override
  List<Object> get props => [selectedItem];

  NavigationState copyWith({NavigationItem? selectedItem}) {
    return NavigationState(selectedItem: selectedItem ?? this.selectedItem);
  }
}
