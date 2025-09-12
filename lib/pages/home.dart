// lib/screens/map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/map/map_bloc.dart';
import '../bloc/map/map_event.dart';
import '../bloc/map/map_state.dart';
import '../models/place.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../widgets/top_bar.dart';
import '../widgets/sos_button.dart';
import '../widgets/map_marker.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Load places when the screen initializes
    context.read<MapBloc>().add(LoadPlaces());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<MapBloc, MapState>(
          listener: (context, state) {
            if (state.status == MapStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: Stack(
            children: [
              // Map Layer (Background)
              _buildMapLayer(),
              
              // UI Overlay Layer (Foreground)
              _buildUIOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapLayer() {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: state.mapCenter,
            initialZoom: state.mapZoom,
            minZoom: 3.0,
            maxZoom: 18.0,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                context.read<MapBloc>().add(UpdateMapCenter(position.center!));
                context.read<MapBloc>().add(UpdateMapZoom(position.zoom!));
              }
            },
            onTap: (tapPosition, point) {
              // Clear selected place when tapping on empty map
              context.read<MapBloc>().add(const SelectPlace(null));
            },
          ),
          children: [
            // OpenStreetMap Tile Layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.humanitarian_aid',
              maxZoom: 19,
            ),
            
            // Markers Layer
            MarkerLayer(
              markers: _buildMarkers(state),
            ),
          ],
        );
      },
    );
  }

  List<Marker> _buildMarkers(MapState state) {
    return state.filteredPlaces.map((place) {
      final isSelected = state.selectedPlace?.id == place.id;
      
      return Marker(
        point: place.position,
        width: isSelected ? 40 : 32,
        height: isSelected ? 40 : 32,
        child: MapMarkerWidget(
          place: place,
          isSelected: isSelected,
          onTap: () {
            context.read<MapBloc>().add(SelectPlace(place));
            _showPlaceDetails(place);
          },
        ),
      );
    }).toList();
  }

  Widget _buildUIOverlay() {
    return Column(
      children: [
        // Top Bar
        TopBar(
          onMenuTap: () => Scaffold.of(context).openDrawer(),
          onNotificationTap: () {
            // Handle notification tap
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications clicked')),
            );
          },
        ),
        
        // Map Content Area
        Expanded(
          child: Stack(
            children: [
              // SOS Button positioned at bottom right
              Positioned(
                bottom: 32,
                right: 16,
                child: const SOSButton(),
              ),
              
              // Loading Overlay
              BlocBuilder<MapBloc, MapState>(
                builder: (context, state) {
                  if (state.status == MapStatus.loading) {
                    return Container(
                      color: Colors.white.withOpacity(0.7),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              // Search Results Counter
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: BlocBuilder<MapBloc, MapState>(
                  builder: (context, state) {
                    if (state.searchQuery?.isNotEmpty == true || state.isFilterActive) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.isFilterActive ? Icons.filter_alt : Icons.search,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${state.filteredPlaces.length} location${state.filteredPlaces.length != 1 ? 's' : ''} found',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            if (state.searchQuery?.isNotEmpty == true || state.isFilterActive) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  if (state.searchQuery?.isNotEmpty == true) {
                                    context.read<MapBloc>().add(ClearSearch());
                                  }
                                  if (state.isFilterActive) {
                                    context.read<MapBloc>().add(ClearFilters());
                                  }
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPlaceDetails(Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsModal(place: place),
    );
  }
}

class PlaceDetailsModal extends StatelessWidget {
  final Place place;

  const PlaceDetailsModal({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and name
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getColorForPlaceType(place.type),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForPlaceType(place.type),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: AppTextStyles.h5,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  place.verificationStatus == VerificationStatus.verified
                                      ? Icons.verified
                                      : Icons.help_outline,
                                  size: 16,
                                  color: place.verificationStatus == VerificationStatus.verified
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  place.verificationStatus == VerificationStatus.verified
                                      ? 'Verified'
                                      : 'Unverified',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: place.verificationStatus == VerificationStatus.verified
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    place.description,
                    style: AppTextStyles.bodyMedium,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Details
                  if (place.address != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.neutral600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            place.address!,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  if (place.contact != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: AppColors.neutral600),
                        const SizedBox(width: 8),
                        Text(
                          place.contact!,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.neutral600),
                      const SizedBox(width: 8),
                      Text(
                        'Updated ${_formatTime(place.createdAt)}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Navigate to location
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navigation feature coming soon')),
                            );
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (place.contact != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Call contact
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Calling ${place.contact}')),
                              );
                            },
                            icon: const Icon(Icons.call),
                            label: const Text('Call'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  IconData _getIconForPlaceType(PlaceType type) {
    switch (type) {
      case PlaceType.medicalCenter:
        return Icons.local_hospital;
      case PlaceType.foodDistribution:
        return Icons.restaurant;
      case PlaceType.waterSource:
        return Icons.water_drop;
      case PlaceType.shelterRefuge:
        return Icons.home;
      case PlaceType.dangerZone:
        return Icons.warning;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}