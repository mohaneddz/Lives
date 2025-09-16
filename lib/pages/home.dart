// lib/screens/map_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../widgets/top_bar.dart';

// API Service Class - Integrated into map_page.dart
class LocationApiService {
  static const String baseUrl = 'https://4-pal-backend.vercel.app/api'; // Replace with your actual API URL
  
  // Fetch all locations from the backend
  static Future<List<Place>> fetchLocations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/locations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List locations = data['data'] ?? data;
        return locations.map((locationData) => Place.fromApiResponse(locationData)).toList();
      } else {
        throw Exception('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching locations: $e');
    }
  }

  // Add a new location to the backend
  // Add a new location to the backend
// Add a new location to the backend
static Future<Place> addLocation(Map<String, dynamic> locationData) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/locations/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(locationData),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Your API returns 200, not 201
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        
        // Check if the request was successful
        if (data['success'] == true && data['data'] != null && data['data'].isNotEmpty) {
          // Extract the location_id from your API response structure
          final locationId = data['data'][0]['location_id'] as int;
          return Place.fromLocationData(locationData, locationId);
        } else {
          throw Exception('API returned success=false or no data');
        }
      } catch (parseError) {
        throw Exception('Failed to parse response: $parseError');
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add location: ${response.statusCode}');
      } catch (e) {
        throw Exception('Request failed with status ${response.statusCode}: ${response.body}');
      }
    }
  } catch (e) {
    if (e is Exception) {
      rethrow;
    }
    throw Exception('Error adding location: $e');
  }
}

  // Verify a location (admin only)
  static Future<bool> verifyLocation({
    required int locationId,
    required int adminId,
    required String status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/locations/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'location_id': locationId,
          'admin_id': adminId,
          'status': status,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error verifying location: $e');
    }
  }
}

// Enhanced Place Model - Integrated into map_page.dart
enum PlaceType {
  medicalCenter,
  foodDistribution, 
  waterSource,
  shelterRefuge,
  dangerZone,
}

enum VerificationStatus {
  verified,
  unverified,
}

class Place {
  final int id;
  final String name;
  final String description;
  final PlaceType type;
  final LatLng position;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final String? address;
  final String? contact;
  final String? organization;
  final String? capacity;
  final String? startTime;
  final String? endTime;
  final int createdBy;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.position,
    required this.verificationStatus,
    required this.createdAt,
    required this.createdBy,
    this.address,
    this.contact,
    this.organization,
    this.capacity,
    this.startTime,
    this.endTime,
  });

  // Factory constructor to create Place from API response
  factory Place.fromApiResponse(Map<String, dynamic> json) {
    PlaceType getPlaceType(String? category) {
      switch (category?.toLowerCase()) {
        case 'medical_facility':
          return PlaceType.medicalCenter;
        case 'food_distribution':
          return PlaceType.foodDistribution;
        case 'water_source':
          return PlaceType.waterSource;
        case 'refuge_camp':
          return PlaceType.shelterRefuge;
        case 'danger_zone':
          return PlaceType.dangerZone;
        default:
          return PlaceType.medicalCenter;
      }
    }

    VerificationStatus getVerificationStatus(dynamic status) {
      if (status == null) return VerificationStatus.unverified;
      if (status.toString().toLowerCase() == 'verified') {
        return VerificationStatus.verified;
      }
      return VerificationStatus.unverified;
    }

    return Place(
      id: json['id'] as int,
      name: json['title'] ?? 'Unnamed Location',
      description: json['description'] ?? '',
      type: getPlaceType(json['category']),
      position: LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      verificationStatus: getVerificationStatus(json['verification_status']),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      createdBy: json['created_by'] as int,
      address: json['address'],
      contact: json['contact'],
      organization: json['organization'],
      capacity: json['capacity'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  // Factory constructor for newly created places
  factory Place.fromLocationData(Map<String, dynamic> locationData, int id) {
    PlaceType getPlaceType(String? category) {
      switch (category?.toLowerCase()) {
        case 'medical_facility':
          return PlaceType.medicalCenter;
        case 'food_distribution':
          return PlaceType.foodDistribution;
        case 'water_source':
          return PlaceType.waterSource;
        case 'refuge_camp':
          return PlaceType.shelterRefuge;
        case 'danger_zone':
          return PlaceType.dangerZone;
        default:
          return PlaceType.medicalCenter;
      }
    }

    return Place(
      id: id,
      name: locationData['title'] ?? 'Unnamed Location',
      description: locationData['description'] ?? '',
      type: getPlaceType(locationData['category']),
      position: LatLng(
        (locationData['latitude'] as num).toDouble(),
        (locationData['longitude'] as num).toDouble(),
      ),
      verificationStatus: VerificationStatus.unverified,
      createdAt: DateTime.now(),
      createdBy: locationData['created_by'] as int,
      address: locationData['address'],
      contact: null, // Not provided in location data
      organization: locationData['organization'],
      capacity: locationData['capacity'],
      startTime: locationData['start_time'],
      endTime: locationData['end_time'],
    );
  }

  Place copyWith({
    int? id,
    String? name,
    String? description,
    PlaceType? type,
    LatLng? position,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    String? address,
    String? contact,
    String? organization,
    String? capacity,
    String? startTime,
    String? endTime,
    int? createdBy,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      position: position ?? this.position,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      organization: organization ?? this.organization,
      capacity: capacity ?? this.capacity,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

// Enhanced Map Events - Integrated into map_page.dart
abstract class MapEvent {}

class LoadPlaces extends MapEvent {}

class RefreshPlaces extends MapEvent {}

class AddNewPlace extends MapEvent {
  final Map<String, dynamic> placeData;
  final int currentUserId;
  
  AddNewPlace({required this.placeData, required this.currentUserId});
}

class UpdateMapCenter extends MapEvent {
  final LatLng center;
  UpdateMapCenter(this.center);
}

class UpdateMapZoom extends MapEvent {
  final double zoom;
  UpdateMapZoom(this.zoom);
}

class SelectPlace extends MapEvent {
  final Place? place;
   SelectPlace(this.place);
}

class SearchPlaces extends MapEvent {
  final String query;
  SearchPlaces(this.query);
}

class ClearSearch extends MapEvent {}

class FilterPlaces extends MapEvent {
  final List<PlaceType> types;
  final VerificationStatus? verificationStatus;
  
  FilterPlaces({required this.types, this.verificationStatus});
}

class ClearFilters extends MapEvent {}

// Main MapPage Widget
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLocationInitialized = false;
  bool _isLoadingPlaces = false;
  List<Place> _places = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAndGetLocation();
    _loadPlaces();
  }

  // Load places from API
  Future<void> _loadPlaces() async {
    setState(() {
      _isLoadingPlaces = true;
      _errorMessage = null;
    });

    try {
      final places = await LocationApiService.fetchLocations();
      setState(() {
        _places = places;
        _isLoadingPlaces = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingPlaces = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load locations: ${e.toString()}'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadPlaces,
          ),
        ),
      );
    }
  }

  // Refresh places from API
  Future<void> _refreshPlaces() async {
    try {
      final places = await LocationApiService.fetchLocations();
      setState(() {
        _places = places;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Locations refreshed'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Add new place via API
  Future<void> _addNewPlace(Map<String, dynamic> placeData) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Adding location...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      const int currentUserId = 1; // Replace with actual user ID from auth system
      final placeDataWithUser = {
        ...placeData,
        'created_by': currentUserId,
      };

      final newPlace = await LocationApiService.addLocation(placeDataWithUser);
      
      setState(() {
        _places = [..._places, newPlace];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('${placeData['title']} added successfully!')),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add location: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _checkAndGetLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationPermissionPermanentlyDeniedDialog();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLocationInitialized = true;
      });

      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
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
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
        child: Stack(
          children: [
            // Map Layer (Background)
            _buildMapLayer(),
            
            // UI Overlay Layer (Foreground)
            _buildUIOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapLayer() {
    // Don't show map until we have user's location
    if (_currentPosition == null) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Getting your location...',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error state for location loading
    if (_errorMessage != null && _places.isEmpty && !_isLoadingPlaces) {
      return Container(
        color: AppColors.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load locations',
                style: AppTextStyles.h6.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unknown error occurred',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPlaces,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition!,
        initialZoom: 15.0,
        minZoom: 3.0,
        maxZoom: 18.0,
        onPositionChanged: (position, hasGesture) {
          // Optional: Update state if using BLoC
        },
        onTap: (tapPosition, point) {
          // Clear selected place when tapping on empty map
        },
        onLongPress: (tapPosition, point) {
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
        
        // Current Location Layer
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
          markers: _buildMarkers(),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    return _places.map((place) {
      return Marker(
        point: place.position,
        width: 32,
        height: 32,
        child: GestureDetector(
          onTap: () => _showPlaceDetails(place),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getColorForPlaceType(place.type),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              _getIconForPlaceType(place.type),
              color: Colors.white,
              size: 16,
            ),
          ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications clicked')),
            );
          },
        ),
        
        // Map Content Area
        Expanded(
          child: Stack(
            children: [
              // Places counter
              if (_places.isNotEmpty)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        const Icon(Icons.place, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${_places.length} location${_places.length != 1 ? 's' : ''} found',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Refresh Button (top-right)
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: "refresh_locations",
                  backgroundColor: AppColors.surface,
                  onPressed: _refreshPlaces,
                  child: const Icon(Icons.refresh, color: AppColors.primary),
                ),
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
                        CircularProgressIndicator(color: AppColors.primary),
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
              
              // Loading overlay for places
              if (_isLoadingPlaces && _isLocationInitialized)
                Container(
                  color: Colors.white.withOpacity(0.7),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddPlaceDialog(LatLng position) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController organizationController = TextEditingController();
    final TextEditingController capacityController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    
    PlaceType? selectedCategory;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    
    // List of available categories matching your database enum
    final List<(PlaceType, IconData, String)> categories = [
      (PlaceType.medicalCenter, Icons.local_hospital, 'Medical Facility'),
      (PlaceType.foodDistribution, Icons.restaurant, 'Food Distribution'),
      (PlaceType.waterSource, Icons.water_drop, 'Water Source'),
      (PlaceType.shelterRefuge, Icons.home, 'Refuge Camp'),
      (PlaceType.dangerZone, Icons.warning, 'Danger Zone'),
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_location_alt, color: AppColors.primary, size: 24),
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
                      const Icon(Icons.location_on, size: 16, color: AppColors.neutral600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Category Selection (Required)
                Text('Category *', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
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
                              Icon(icon, color: isSelected ? AppColors.primary : AppColors.neutral600, size: 20),
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
                                const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title (Required)
                Text('Title *', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Red Crescent Food Distribution',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Description (Required)
                Text('Description *', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g., Hot meals for families',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Address (Optional)
                Text('Address', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: 'Will be auto-filled based on location',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                    prefixIcon: const Icon(Icons.location_on, size: 20),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Organization (Optional)
                Text('Organization', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: organizationController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Palestinian Red Crescent',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                    prefixIcon: const Icon(Icons.business, size: 20),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Capacity (Optional)
                Text('Capacity', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: capacityController,
                  decoration: InputDecoration(
                    hintText: 'e.g., 500 meals, 100 people, 50 beds',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                          Text('Start Time', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
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
                          Text('End Time', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
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
                    const Icon(Icons.info_outline, size: 16, color: AppColors.neutral500),
                    const SizedBox(width: 4),
                    Text(
                      'Fields marked with * are required',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
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
              onPressed: () async {
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
                
                // Convert PlaceType to API category string
                String getApiCategory(PlaceType type) {
                  switch (type) {
                    case PlaceType.medicalCenter:
                      return 'medical_facility';
                    case PlaceType.foodDistribution:
                      return 'food_distribution';
                    case PlaceType.waterSource:
                      return 'water_source';
                    case PlaceType.shelterRefuge:
                      return 'refuge_camp';
                    case PlaceType.dangerZone:
                      return 'danger_zone';
                  }
                }
                
                // Create the place data according to your API schema
                final placeData = {
                  "latitude": position.latitude,
                  "longitude": position.longitude,
                  "address": addressController.text.trim().isNotEmpty 
                    ? addressController.text.trim() 
                    : "Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}",
                  "category": getApiCategory(selectedCategory!),
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
                
                // Add the place through the API
                await _addNewPlace(placeData);
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

  void _showPlaceDetails(Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsModal(place: place),
    );
  }

  Color _getColorForPlaceType(PlaceType type) {
    switch (type) {
      case PlaceType.medicalCenter:
        return Colors.red;
      case PlaceType.foodDistribution:
        return Colors.orange;
      case PlaceType.waterSource:
        return Colors.blue;
      case PlaceType.shelterRefuge:
        return Colors.green;
      case PlaceType.dangerZone:
        return Colors.redAccent;
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
}

// Place Details Modal Widget
class PlaceDetailsModal extends StatelessWidget {
  final Place place;

  const PlaceDetailsModal({super.key, required this.place});

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
                            Text(place.name, style: AppTextStyles.h5),
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
                  Text(place.description, style: AppTextStyles.bodyMedium),
                  
                  const SizedBox(height: 16),
                  
                  // Details
                  if (place.address != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.neutral600),
                        const SizedBox(width: 8),
                        Expanded(child: Text(place.address!, style: AppTextStyles.bodySmall)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  if (place.organization != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.business, size: 16, color: AppColors.neutral600),
                        const SizedBox(width: 8),
                        Text(place.organization!, style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  if (place.capacity != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.groups, size: 16, color: AppColors.neutral600),
                        const SizedBox(width: 8),
                        Text(place.capacity!, style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  if (place.startTime != null || place.endTime != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: AppColors.neutral600),
                        const SizedBox(width: 8),
                        Text(
                          '${place.startTime ?? 'Open'} - ${place.endTime ?? 'Close'}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: AppColors.neutral600),
                      const SizedBox(width: 8),
                      Text(
                        'Added ${_formatTime(place.createdAt)}',
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
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Contact feature coming soon')),
                            );
                          },
                          icon: const Icon(Icons.info),
                          label: const Text('Info'),
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
        return Colors.red;
      case PlaceType.foodDistribution:
        return Colors.orange;
      case PlaceType.waterSource:
        return Colors.blue;
      case PlaceType.shelterRefuge:
        return Colors.green;
      case PlaceType.dangerZone:
        return Colors.redAccent;
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