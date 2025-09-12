import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../models/place.dart';

enum MapStatus { initial, loading, loaded, error }

class MapState extends Equatable {
  final MapStatus status;
  final List<Place> places;
  final List<Place> filteredPlaces;
  final String? searchQuery;
  final List<PlaceType>? selectedLocationTypes;
  final double? selectedDistance;
  final VerificationStatus? selectedVerificationStatus;
  final bool? activeOnly;
  final bool? recentOnly;
  final bool? scheduledOnly;
  final LatLng mapCenter;
  final double mapZoom;
  final Place? selectedPlace;
  final String? errorMessage;
  final bool isFilterActive;
  final bool isSosActive;

  const MapState({
    this.status = MapStatus.initial,
    this.places = const [],
    this.filteredPlaces = const [],
    this.searchQuery,
    this.selectedLocationTypes,
    this.selectedDistance,
    this.selectedVerificationStatus,
    this.activeOnly,
    this.recentOnly,
    this.scheduledOnly,
    this.mapCenter = const LatLng(36.1897, 5.4140), // Sétif coordinates
    this.mapZoom = 13.0,
    this.selectedPlace,
    this.errorMessage,
    this.isFilterActive = false,
    this.isSosActive = false,
  });

  MapState copyWith({
    MapStatus? status,
    List<Place>? places,
    List<Place>? filteredPlaces,
    String? searchQuery,
    List<PlaceType>? selectedLocationTypes,
    double? selectedDistance,
    VerificationStatus? selectedVerificationStatus,
    bool? activeOnly,
    bool? recentOnly,
    bool? scheduledOnly,
    LatLng? mapCenter,
    double? mapZoom,
    Place? selectedPlace,
    String? errorMessage,
    bool? isFilterActive,
    bool? isSosActive,
  }) {
    return MapState(
      status: status ?? this.status,
      places: places ?? this.places,
      filteredPlaces: filteredPlaces ?? this.filteredPlaces,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedLocationTypes: selectedLocationTypes ?? this.selectedLocationTypes,
      selectedDistance: selectedDistance ?? this.selectedDistance,
      selectedVerificationStatus: selectedVerificationStatus ?? this.selectedVerificationStatus,
      activeOnly: activeOnly ?? this.activeOnly,
      recentOnly: recentOnly ?? this.recentOnly,
      scheduledOnly: scheduledOnly ?? this.scheduledOnly,
      mapCenter: mapCenter ?? this.mapCenter,
      mapZoom: mapZoom ?? this.mapZoom,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      errorMessage: errorMessage ?? this.errorMessage,
      isFilterActive: isFilterActive ?? this.isFilterActive,
      isSosActive: isSosActive ?? this.isSosActive,
    );
  }

  // Clear search query
  MapState clearSearch() {
    return copyWith(
      searchQuery: '',
      filteredPlaces: places,
    );
  }

  // Clear all filters
  MapState clearFilters() {
    return copyWith(
      selectedLocationTypes: null,
      selectedDistance: null,
      selectedVerificationStatus: null,
      activeOnly: null,
      recentOnly: null,
      scheduledOnly: null,
      filteredPlaces: places,
      isFilterActive: false,
    );
  }

  @override
  List<Object?> get props => [
        status,
        places,
        filteredPlaces,
        searchQuery,
        selectedLocationTypes,
        selectedDistance,
        selectedVerificationStatus,
        activeOnly,
        recentOnly,
        scheduledOnly,
        mapCenter,
        mapZoom,
        selectedPlace,
        errorMessage,
        isFilterActive,
        isSosActive,
      ];
}