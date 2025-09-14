import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/map_service.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapService _mapService;

  MapBloc({MapService? mapService})
      : _mapService = mapService ?? MapService(),
        super(const MapState()) {
    
    on<LoadPlaces>(_onLoadPlaces);
    on<FilterPlaces>(_onFilterPlaces);
    on<SearchPlaces>(_onSearchPlaces);
    on<ClearFilters>(_onClearFilters);
    on<ClearSearch>(_onClearSearch);
    on<UpdateMapCenter>(_onUpdateMapCenter);
    on<UpdateMapZoom>(_onUpdateMapZoom);
    on<SelectPlace>(_onSelectPlace);
    on<TriggerSOS>(_onTriggerSOS);
  }

  Future<void> _onLoadPlaces(LoadPlaces event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: MapStatus.loading));
    
    try {
      final places = await _mapService.fetchPlaces();
      emit(state.copyWith(
        status: MapStatus.loaded,
        places: places,
        filteredPlaces: places,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: MapStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onFilterPlaces(FilterPlaces event, Emitter<MapState> emit) async {
    final filteredPlaces = _mapService.filterPlaces(
      state.places,
      locationTypes: event.locationTypes,
      distance: event.distance,
      verificationStatus: event.verificationStatus,
      activeOnly: event.activeOnly,
      recentOnly: event.recentOnly,
      scheduledOnly: event.scheduledOnly,
      userLocation: state.mapCenter,
    );

    final hasFilters = event.locationTypes?.isNotEmpty == true ||
        event.distance != null ||
        event.verificationStatus != null ||
        event.activeOnly == true ||
        event.recentOnly == true ||
        event.scheduledOnly == true;

    emit(state.copyWith(
      filteredPlaces: filteredPlaces,
      selectedLocationTypes: event.locationTypes,
      selectedDistance: event.distance,
      selectedVerificationStatus: event.verificationStatus,
      activeOnly: event.activeOnly,
      recentOnly: event.recentOnly,
      scheduledOnly: event.scheduledOnly,
      isFilterActive: hasFilters,
    ));
  }

  Future<void> _onSearchPlaces(SearchPlaces event, Emitter<MapState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        filteredPlaces: state.places,
      ));
      return;
    }

    final searchResults = await _mapService.searchPlaces(event.query, state.places);
    
    emit(state.copyWith(
      searchQuery: event.query,
      filteredPlaces: searchResults,
    ));
  }

  void _onClearFilters(ClearFilters event, Emitter<MapState> emit) {
    emit(state.clearFilters());
  }

  void _onClearSearch(ClearSearch event, Emitter<MapState> emit) {
    emit(state.clearSearch());
  }

  void _onUpdateMapCenter(UpdateMapCenter event, Emitter<MapState> emit) {
    emit(state.copyWith(mapCenter: event.center));
  }

  void _onUpdateMapZoom(UpdateMapZoom event, Emitter<MapState> emit) {
    emit(state.copyWith(mapZoom: event.zoom));
  }

  void _onSelectPlace(SelectPlace event, Emitter<MapState> emit) {
    emit(state.copyWith(selectedPlace: event.place));
  }

  Future<void> _onTriggerSOS(TriggerSOS event, Emitter<MapState> emit) async {
    emit(state.copyWith(isSosActive: true));
    
    try {
      await _mapService.sendSOSAlert(event.location);
      // In a real app, you might show a success message or update UI
      emit(state.copyWith(isSosActive: false));
    } catch (error) {
      emit(state.copyWith(
        isSosActive: false,
        errorMessage: 'Failed to send SOS alert: ${error.toString()}',
      ));
    }
  }
}