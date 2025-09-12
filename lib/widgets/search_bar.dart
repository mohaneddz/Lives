import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/map/map_bloc.dart';
import '../bloc/map/map_event.dart';
import '../bloc/map/map_state.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text;
    context.read<MapBloc>().add(SearchPlaces(query));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listener: (context, state) {
        if (state.searchQuery != _controller.text) {
          _controller.text = state.searchQuery ?? '';
        }
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'search',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutral500,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.neutral500,
              size: 20,
            ),
            suffixIcon: BlocBuilder<MapBloc, MapState>(
              builder: (context, state) {
                if (state.searchQuery?.isNotEmpty == true) {
                  return IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.neutral500,
                      size: 20,
                    ),
                    onPressed: () {
                      _controller.clear();
                      context.read<MapBloc>().add(const SearchPlaces(''));
                      _focusNode.unfocus();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onSubmitted: (value) {
            _focusNode.unfocus();
          },
        ),
      ),
    );
  }
}