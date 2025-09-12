import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/map/map_bloc.dart';
import '../bloc/map/map_event.dart';
import '../bloc/map/map_state.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../models/place.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: state.isFilterActive ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showFilterModal(context, state),
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Stack(
                  children: [
                    Icon(
                      Icons.tune,
                      color: state.isFilterActive 
                          ? AppColors.onPrimary 
                          : AppColors.neutral600,
                      size: 20,
                    ),
                    if (state.isFilterActive)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterModal(BuildContext context, MapState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(currentState: state),
    );
  }
}

class FilterModal extends StatefulWidget {
  final MapState currentState;

  const FilterModal({
    super.key,
    required this.currentState,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  List<PlaceType>? selectedLocationTypes;
  double? selectedDistance;
  VerificationStatus? selectedVerificationStatus;
  bool? activeOnly;
  bool? recentOnly;
  bool? scheduledOnly;

  @override
  void initState() {
    super.initState();
    // Initialize with current state values
    selectedLocationTypes = widget.currentState.selectedLocationTypes;
    selectedDistance = widget.currentState.selectedDistance;
    selectedVerificationStatus = widget.currentState.selectedVerificationStatus;
    activeOnly = widget.currentState.activeOnly;
    recentOnly = widget.currentState.recentOnly;
    scheduledOnly = widget.currentState.scheduledOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.neutral200),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Filter Locations',
                  style: AppTextStyles.h5,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text(
                    'Clear all',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Types
                  _buildSectionTitle('Location Types'),
                  const SizedBox(height: 12),
                  _buildLocationTypeFilters(),
                  
                  const SizedBox(height: 24),
                  
                  // Distance
                  _buildSectionTitle('Distance'),
                  const SizedBox(height: 12),
                  _buildDistanceFilters(),
                  
                  const SizedBox(height: 24),
                  
                  // Verification Status
                  _buildSectionTitle('Verification Status'),
                  const SizedBox(height: 12),
                  _buildVerificationFilters(),
                  
                  const SizedBox(height: 24),
                  
                  // Time
                  _buildSectionTitle('Time'),
                  const SizedBox(height: 12),
                  _buildTimeFilters(),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.neutral200),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Apply'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelLarge,
    );
  }

  Widget _buildLocationTypeFilters() {
    final locationTypes = [
      (PlaceType.medicalCenter, Icons.local_hospital, 'Medical Centers'),
      (PlaceType.foodDistribution, Icons.restaurant, 'Food Distribution'),
      (PlaceType.waterSource, Icons.water_drop, 'Water Sources'),
      (PlaceType.shelterRefuge, Icons.home, 'Shelter/Refuge'),
      (PlaceType.dangerZone, Icons.warning, 'Danger Zones'),
    ];

    return Column(
      children: locationTypes.map((item) {
        final isSelected = selectedLocationTypes?.contains(item.$1) ?? false;
        return CheckboxListTile(
          value: isSelected,
          onChanged: (value) => _toggleLocationType(item.$1),
          title: Row(
            children: [
              Icon(item.$2, size: 20, color: _getColorForPlaceType(item.$1)),
              const SizedBox(width: 8),
              Text(item.$3, style: AppTextStyles.bodyMedium),
            ],
          ),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildDistanceFilters() {
    final distances = [500.0 , 1000.0, 2000.0, 5000.0, 10000.0, null];
    final distanceLabels = ['500m', '1km', '2km', '5km', '10km', 'All distances'];

    return Column(
      children: List.generate(distances.length, (index) {
        final distance = distances[index];
        final label = distanceLabels[index];
        final isSelected = selectedDistance == distance;

        return RadioListTile<double?>(
          value: distance,
          groupValue: selectedDistance,
          onChanged: (value) => setState(() => selectedDistance = value),
          title: Text(label, style: AppTextStyles.bodyMedium),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        );
      }),
    );
  }

  Widget _buildVerificationFilters() {
    return Column(
      children: [
        RadioListTile<VerificationStatus?>(
          value: null,
          groupValue: selectedVerificationStatus,
          onChanged: (value) => setState(() => selectedVerificationStatus = value),
          title: const Text('All locations', style: AppTextStyles.bodyMedium),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<VerificationStatus?>(
          value: VerificationStatus.verified,
          groupValue: selectedVerificationStatus,
          onChanged: (value) => setState(() => selectedVerificationStatus = value),
          title: const Text('Verified only', style: AppTextStyles.bodyMedium),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<VerificationStatus?>(
          value: VerificationStatus.unverified,
          groupValue: selectedVerificationStatus,
          onChanged: (value) => setState(() => selectedVerificationStatus = value),
          title: const Text('Unverified only', style: AppTextStyles.bodyMedium),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildTimeFilters() {
    return Column(
      children: [
        RadioListTile<String>(
          value: 'all',
          groupValue: _getSelectedTimeFilter(),
          onChanged: (value) => _setTimeFilter('all'),
          title: const Text('All time', style: AppTextStyles.bodyMedium),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          value: 'recent',
          groupValue: _getSelectedTimeFilter(),
          onChanged: (value) => _setTimeFilter('recent'),
          title: const Text('Recent (24h)', style: AppTextStyles.bodyMedium),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          value: 'active',
          groupValue: _getSelectedTimeFilter(),
          onChanged: (value) => _setTimeFilter('active'),
          title: const Text('Active now', style: AppTextStyles.bodyMedium),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          value: 'scheduled',
          groupValue: _getSelectedTimeFilter(),
          onChanged: (value) => _setTimeFilter('scheduled'),
          title: const Text('Scheduled', style: AppTextStyles.bodyMedium),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _toggleLocationType(PlaceType type) {
    setState(() {
      selectedLocationTypes ??= [];
      if (selectedLocationTypes!.contains(type)) {
        selectedLocationTypes!.remove(type);
        if (selectedLocationTypes!.isEmpty) {
          selectedLocationTypes = null;
        }
      } else {
        selectedLocationTypes!.add(type);
      }
    });
  }

  String _getSelectedTimeFilter() {
    if (recentOnly == true) return 'recent';
    if (activeOnly == true) return 'active';
    if (scheduledOnly == true) return 'scheduled';
    return 'all';
  }

  void _setTimeFilter(String filter) {
    setState(() {
      recentOnly = filter == 'recent';
      activeOnly = filter == 'active';
      scheduledOnly = filter == 'scheduled';
      if (filter == 'all') {
        recentOnly = null;
        activeOnly = null;
        scheduledOnly = null;
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      selectedLocationTypes = null;
      selectedDistance = null;
      selectedVerificationStatus = null;
      activeOnly = null;
      recentOnly = null;
      scheduledOnly = null;
    });
  }

  void _applyFilters() {
    context.read<MapBloc>().add(FilterPlaces(
      locationTypes: selectedLocationTypes,
      distance: selectedDistance,
      verificationStatus: selectedVerificationStatus,
      activeOnly: activeOnly,
      recentOnly: recentOnly,
      scheduledOnly: scheduledOnly,
    ));
    Navigator.pop(context);
  }

  Color _getColorForPlaceType(PlaceType type) {
    switch (type) {
      case PlaceType.medicalCenter:
        return AppColors.medicalCenter;
      case PlaceType.foodDistribution:
        return AppColors.foodDistribution;
      case PlaceType.waterSource:
        return AppColors.waterSource;
      case PlaceType.shelterRefuge:
        return AppColors.shelterRefuge;
      case PlaceType.dangerZone:
        return AppColors.dangerZone;
    }
  }
}