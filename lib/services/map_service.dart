import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/place.dart';

class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  // Mock data for demonstration
  Future<List<Place>> fetchPlaces() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock places around Sétif
    final Random random = Random();
    final List<Place> places = [];

    // Sétif center coordinates
    const double centerLat = 36.1897;
    const double centerLng = 5.4140;

    final placeNames = {
      PlaceType.medicalCenter: [
        'Centre Hospitalier',
        'Clinique Al-Amal',
        'Hôpital Saâdna Abdenour',
        'Centre de Santé',
        'Polyclinique',
      ],
      PlaceType.foodDistribution: [
        'Distribution Alimentaire Centre',
        'Aide Alimentaire Mosquée',
        'Centre de Distribution',
        'Point de Collecte',
        'Distribution Humanitaire',
      ],
      PlaceType.waterSource: [
        'Source d\'Eau Potable',
        'Fontaine Publique',
        'Point d\'Eau',
        'Station d\'Eau',
        'Puits Communautaire',
      ],
      PlaceType.shelterRefuge: [
        'Refuge d\'Urgence',
        'Centre d\'Hébergement',
        'Abri Temporaire',
        'Foyer d\'Accueil',
        'Centre d\'Accueil',
      ],
      PlaceType.dangerZone: [
        'Zone à Risque',
        'Zone Sinistrée',
        'Zone Interdite',
        'Zone Dangereuse',
        'Périmètre de Sécurité',
      ],
    };

    for (int i = 0; i < 20; i++) {
      final placeType = PlaceType.values[random.nextInt(PlaceType.values.length)];
      final names = placeNames[placeType]!;
      final name = names[random.nextInt(names.length)];
      
      // Generate coordinates within ~10km radius of Sétif
      final double latOffset = (random.nextDouble() - 0.5) * 0.1; // ~11km
      final double lngOffset = (random.nextDouble() - 0.5) * 0.1;
      
      places.add(Place(
        id: 'place_$i',
        name: '$name ${i + 1}',
        description: _getDescriptionForType(placeType),
        position: LatLng(centerLat + latOffset, centerLng + lngOffset),
        type: placeType,
        verificationStatus: random.nextBool() 
            ? VerificationStatus.verified 
            : VerificationStatus.unverified,
        createdAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
        isActive: random.nextDouble() > 0.1, // 90% active
        contact: random.nextBool() ? '+213 ${random.nextInt(100000000)}' : null,
        address: 'Sétif, Algérie',
      ));
    }

    return places;
  }

  String _getDescriptionForType(PlaceType type) {
    switch (type) {
      case PlaceType.medicalCenter:
        return 'Centre médical offrant des soins de santé d\'urgence et des services médicaux.';
      case PlaceType.foodDistribution:
        return 'Point de distribution alimentaire pour les personnes dans le besoin.';
      case PlaceType.waterSource:
        return 'Source d\'eau potable accessible au public.';
      case PlaceType.shelterRefuge:
        return 'Refuge temporaire offrant un hébergement d\'urgence.';
      case PlaceType.dangerZone:
        return 'Zone présentant des risques pour la sécurité. Éviter si possible.';
    }
  }

  Future<void> sendSOSAlert(LatLng location) async {
    // Simulate sending SOS alert
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would send the alert to emergency services
    print('SOS Alert sent from location: ${location.latitude}, ${location.longitude}');
  }

  Future<List<Place>> searchPlaces(String query, List<Place> places) async {
    if (query.isEmpty) return places;

    // Simulate search delay
    await Future.delayed(const Duration(milliseconds: 300));

    return places.where((place) =>
        place.name.toLowerCase().contains(query.toLowerCase()) ||
        place.description.toLowerCase().contains(query.toLowerCase()) ||
        place.address?.toLowerCase().contains(query.toLowerCase()) == true
    ).toList();
  }

  List<Place> filterPlaces(
    List<Place> places, {
    List<PlaceType>? locationTypes,
    double? distance,
    VerificationStatus? verificationStatus,
    bool? activeOnly,
    bool? recentOnly,
    bool? scheduledOnly,
    LatLng? userLocation,
  }) {
    print('🔍 MapService.filterPlaces called');
    print('📍 Input places count: ${places.length}');
    print('🏷️ Location types filter: $locationTypes');
    print('📏 Distance filter: $distance');
    print('✅ Verification filter: $verificationStatus');
    print('⏰ Active only: $activeOnly');
    print('🕐 Recent only: $recentOnly');
    print('📅 Scheduled only: $scheduledOnly');
    print('📍 User location: $userLocation');

    List<Place> filtered = List.from(places);
    print('📊 Starting with ${filtered.length} places');

    // Filter by location types
    if (locationTypes != null && locationTypes.isNotEmpty) {
      print('🏷️ Applying location type filter...');
      final beforeCount = filtered.length;
      filtered = filtered.where((place) => locationTypes.contains(place.type)).toList();
      print('🏷️ After location type filter: ${filtered.length} (was $beforeCount)');
      
      // Debug: show what types we found
      final foundTypes = filtered.map((p) => p.type).toSet();
      print('🏷️ Found types: $foundTypes');
    }

    // Filter by verification status
    if (verificationStatus != null) {
      print('✅ Applying verification filter...');
      final beforeCount = filtered.length;
      if (verificationStatus == VerificationStatus.verified) {
        filtered = filtered.where((place) => place.verificationStatus == VerificationStatus.verified).toList();
      } else {
        filtered = filtered.where((place) => place.verificationStatus == VerificationStatus.unverified).toList();
      }
      print('✅ After verification filter: ${filtered.length} (was $beforeCount)');
    }

    // Filter by active status
    if (activeOnly == true) {
      print('⏰ Applying active only filter...');
      final beforeCount = filtered.length;
      filtered = filtered.where((place) => place.isActive).toList();
      print('⏰ After active filter: ${filtered.length} (was $beforeCount)');
    }

    // Filter by recent (last 24 hours)
    if (recentOnly == true) {
      print('🕐 Applying recent only filter...');
      final beforeCount = filtered.length;
      final yesterday = DateTime.now().subtract(const Duration(hours: 24));
      filtered = filtered.where((place) => place.createdAt.isAfter(yesterday)).toList();
      print('🕐 After recent filter: ${filtered.length} (was $beforeCount)');
      print('🕐 Cutoff date: $yesterday');
    }

    // Filter by distance (if user location is provided)
    if (distance != null && userLocation != null) {
      print('📏 Applying distance filter...');
      final beforeCount = filtered.length;
      final Distance distanceCalc = const Distance();
      filtered = filtered.where((place) {
        final distanceInMeters = distanceCalc(userLocation, place.position);
        final distanceInKm = distanceInMeters / 1000;
        final withinRange = distanceInMeters <= distance;
        if (!withinRange) {
          print('📏 Excluding ${place.name}: ${distanceInKm.toStringAsFixed(2)}km > ${distance/1000}km');
        }
        return withinRange;
      }).toList();
      print('📏 After distance filter: ${filtered.length} (was $beforeCount)');
    }

    // Handle scheduled filter (you might need to add isScheduled property to Place model)
    if (scheduledOnly == true) {
      print('📅 Applying scheduled only filter...');
      final beforeCount = filtered.length;
      // Note: You'll need to add isScheduled property to your Place model
      // For now, let's assume all places could be scheduled
      // filtered = filtered.where((place) => place.isScheduled == true).toList();
      print('📅 Scheduled filter not implemented yet - skipping');
    }

    print('✅ Final filtered places count: ${filtered.length}');
    
    // Debug: show final place names
    if (filtered.length <= 10) {
      print('📋 Filtered places: ${filtered.map((p) => p.name).join(', ')}');
    }
    
    return filtered;
  }
}