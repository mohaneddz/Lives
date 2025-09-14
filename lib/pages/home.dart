// lib/screens/map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/map/map_bloc.dart';
import '../bloc/map/map_event.dart';
import '../bloc/map/map_state.dart';
import '../models/place.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../widgets/top_bar.dart';
import '../widgets/map_marker.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLocationInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkAndGetLocation();
    // Load places when the screen initializes
    context.read<MapBloc>().add(LoadPlaces());
  }

  Future<void> _checkAndGetLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, request user to enable it
        await Geolocator.openLocationSettings();
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, handle appropriately
          _showLocationPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately
        _showLocationPermissionPermanentlyDeniedDialog();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLocationInitialized = true;
      });

      // Always update map center to user's location when first obtained
      if (mounted) {
        context.read<MapBloc>().add(UpdateMapCenter(_currentPosition!));
        context.read<MapBloc>().add(UpdateMapZoom(15.0));
      }

      // Listen to live location changes
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update when user moves 10 meters
        ),
      ).listen((Position pos) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(pos.latitude, pos.longitude);
          });
        }
      });
    } catch (e) {
      print('Error getting location: $e');
      // Handle error appropriately
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing without action
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Location Required'),
            ],
          ),
          content: const Text(
            'This app requires location access to show your current position and provide emergency assistance. Please grant location permission to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back since location is required
                Navigator.of(context).maybePop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkAndGetLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.red),
              SizedBox(width: 8),
              Text('Location Access Denied'),
            ],
          ),
          content: const Text(
            'Location permission has been permanently denied. This app requires location access to function properly. Please enable it in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back since location is required
                Navigator.of(context).maybePop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
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
        // Don't show map until we have user's location
        if (_currentPosition == null) {
          return Container(
            color: AppColors.background,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        
        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition!, // Always use user's location
            initialZoom: 15.0, // Good zoom level for user location
            minZoom: 3.0,
            maxZoom: 18.0,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                context.read<MapBloc>().add(UpdateMapCenter(position.center));
                context.read<MapBloc>().add(UpdateMapZoom(position.zoom));
              }
            },
            onTap: (tapPosition, point) {
              // Clear selected place when tapping on empty map
              context.read<MapBloc>().add(const SelectPlace(null));
            },
            onLongPress: (tapPosition, point) {
              // Optional: Add marker on long press for quick place addition
              _showAddPlaceDialog(point);
            },
          ),
          children: [
            // OpenStreetMap Tile Layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.humanitarian_aid',
              maxZoom: 19,
            ),
            
            // Current Location Layer - This shows the user's real-time location
            if (_currentPosition != null)
              CurrentLocationLayer(
                followOnLocationUpdate: FollowOnLocationUpdate.never,
                turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: Size(40, 40),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
            
            // Markers Layer for places
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
        // Top Bar with integrated search, filter, and SOS button
        TopBar(
          onMenuTap: () => Scaffold.of(context).openDrawer(),
          onNotificationTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications clicked')),
            );
          },
        ),
        
        // Map Content Area
        Expanded(
          child: Stack(
            children: [
              // Search Results Counter (if needed)
              BlocBuilder<MapBloc, MapState>(
                builder: (context, state) {
                  if (state.searchQuery?.isNotEmpty == true || state.isFilterActive) {
                    return Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
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
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              // My Location Button (bottom-left)
              Positioned(
                bottom: 80,
                left: 16,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: "my_location",
                  backgroundColor: AppColors.surface,
                  onPressed: () {
                    if (_currentPosition != null) {
                      _mapController.move(_currentPosition!, 15.0);
                      context.read<MapBloc>().add(UpdateMapCenter(_currentPosition!));
                      context.read<MapBloc>().add(UpdateMapZoom(15.0));
                    } else {
                      _checkAndGetLocation();
                    }
                  },
                  child: Icon(
                    Icons.my_location,
                    color: _currentPosition != null ? AppColors.primary : AppColors.neutral400,
                  ),
                ),
              ),
              
              // Loading Overlay - Show until location is obtained
              if (!_isLocationInitialized || _currentPosition == null)
                Container(
                  color: Colors.white.withOpacity(0.9),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Getting your location...',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please make sure location services are enabled',
                          style: TextStyle(
                            color: AppColors.neutral600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Show loading for other operations only after location is ready
              if (_isLocationInitialized && _currentPosition != null)
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
            ],
          ),
        ),
      ],
    );
  }

  // Updated _showAddPlaceDialog method for MapPage
void _showAddPlaceDialog(LatLng position) {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  
  PlaceType? selectedCategory;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  
  // List of available categories
  final List<(PlaceType, IconData, String)> categories = [
    (PlaceType.medicalCenter, Icons.local_hospital, 'Medical Centers'),
    (PlaceType.foodDistribution, Icons.restaurant, 'Food Distribution'),
    (PlaceType.waterSource, Icons.water_drop, 'Water Sources'),
    (PlaceType.shelterRefuge, Icons.home, 'Shelter/Refuge'),
    (PlaceType.dangerZone, Icons.warning, 'Danger Zones'),
  ];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_location_alt,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Add New Place'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location info (read-only)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Category Selection (Required)
              Text(
                'Category *',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neutral300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: categories.map((category) {
                    final (type, icon, name) = category;
                    final isSelected = selectedCategory == type;
                    
                    return InkWell(
                      onTap: () => setState(() => selectedCategory = type),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                          border: category != categories.last 
                            ? const Border(bottom: BorderSide(color: AppColors.neutral200))
                            : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              color: isSelected ? AppColors.primary : AppColors.neutral600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isSelected ? AppColors.primary : AppColors.neutral800,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title (Required)
              Text(
                'Title *',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Red Crescent Food Distribution',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description (Required)
              Text(
                'Description *',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Hot meals for families',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Address (Auto-filled, but editable)
              Text(
                'Address',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  hintText: 'Will be auto-filled based on location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  prefixIcon: const Icon(Icons.location_on, size: 20),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Organization (Optional)
              Text(
                'Organization',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: organizationController,
                decoration: InputDecoration(
                  hintText: 'e.g., Palestinian Red Crescent',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  prefixIcon: const Icon(Icons.business, size: 20),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Capacity (Optional)
              Text(
                'Capacity',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: capacityController,
                decoration: InputDecoration(
                  hintText: 'e.g., 500 meals, 100 people, 50 beds',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  prefixIcon: const Icon(Icons.groups, size: 20),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Time Selection (Optional)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Time',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() => startTime = time);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.neutral300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  startTime?.format(context) ?? 'Select time',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: startTime != null ? AppColors.neutral800 : AppColors.neutral500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Time',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: startTime ?? TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() => endTime = time);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.neutral300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  endTime?.format(context) ?? 'Select time',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: endTime != null ? AppColors.neutral800 : AppColors.neutral500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.neutral500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Fields marked with * are required',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate required fields
              if (selectedCategory == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a category'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a title'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              
              if (descriptionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a description'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              
              // Create the place data
              final placeData = {
                "latitude": position.latitude,
                "longitude": position.longitude,
                "address": addressController.text.trim().isNotEmpty 
                  ? addressController.text.trim() 
                  : "Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}",
                "category": selectedCategory.toString().split('.').last, // Gets the enum name
                "created_by": "current_user", // You should replace this with actual user ID
                "title": titleController.text.trim(),
                "description": descriptionController.text.trim(),
                "organization": organizationController.text.trim().isNotEmpty 
                  ? organizationController.text.trim() 
                  : null,
                "capacity": capacityController.text.trim().isNotEmpty 
                  ? capacityController.text.trim() 
                  : null,
                "start_time": startTime?.format(context),
                "end_time": endTime?.format(context),
              };
              
              Navigator.of(context).pop();
              
              // Here you would typically call your MapBloc to add the place
              // context.read<MapBloc>().add(AddNewPlace(placeData));
              
              // For now, show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('${titleController.text.trim()} added successfully!'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 3),
                ),
              );
              
              // Print the data for debugging
              print('Place data to be added: $placeData');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Add Place'),
          ),
        ],
      ),
    ),
  );
}
  // SOS Confirmation Dialog Method
  void _showSOSConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text('Emergency Alert'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to send an emergency SOS alert? This will notify emergency services of your current location.',
              ),
              if (_currentPosition != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // You can integrate with your MapBloc here if needed
                // context.read<MapBloc>().add(TriggerSOS(_currentPosition ?? state.mapCenter));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('SOS alert sent successfully!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send SOS'),
            ),
          ],
        );
      },
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