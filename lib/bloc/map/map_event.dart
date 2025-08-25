import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../models/place.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlaces extends MapEvent {}

class FilterPlaces extends MapEvent {
  final List<PlaceType>? locationTypes;
  final double? distance;
  final VerificationStatus? verificationStatus;
  final bool? activeOnly;
  final bool? recentOnly;
  final bool? scheduledOnly;

  const FilterPlaces({
    this.locationTypes,
    this.distance,
    this.verificationStatus,
    this.activeOnly,
    this.recentOnly,
    this.scheduledOnly,
  });

  @override
  List<Object?> get props => [
        locationTypes,
        distance,
        verificationStatus,
        activeOnly,
        recentOnly,
        scheduledOnly,
      ];
}

class SearchPlaces extends MapEvent {
  final String query;

  const SearchPlaces(this.query);

  @override
  List<Object> get props => [query];
}

class ClearFilters extends MapEvent {}

class ClearSearch extends MapEvent {}

class UpdateMapCenter extends MapEvent {
  final LatLng center;

  const UpdateMapCenter(this.center);

  @override
  List<Object> get props => [center];
}

class UpdateMapZoom extends MapEvent {
  final double zoom;

  const UpdateMapZoom(this.zoom);

  @override
  List<Object> get props => [zoom];
}

class SelectPlace extends MapEvent {
  final Place? place;

  const SelectPlace(this.place);

  @override
  List<Object?> get props => [place];
}

class TriggerSOS extends MapEvent {
  final LatLng location;

  const TriggerSOS(this.location);

  @override
  List<Object> get props => [location];
}