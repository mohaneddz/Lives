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
    List<Place> filtered = List.from(places);

    // Filter by location types
    if (locationTypes != null && locationTypes.isNotEmpty) {
      filtered = filtered.where((place) => locationTypes.contains(place.type)).toList();
    }

    // Filter by verification status
    if (verificationStatus != null) {
      if (verificationStatus == VerificationStatus.verified) {
        filtered = filtered.where((place) => place.verificationStatus == VerificationStatus.verified).toList();
      } else {
        filtered = filtered.where((place) => place.verificationStatus == VerificationStatus.unverified).toList();
      }
    }

    // Filter by active status
    if (activeOnly == true) {
      filtered = filtered.where((place) => place.isActive).toList();
    }

    // Filter by recent (last 24 hours)
    if (recentOnly == true) {
      final yesterday = DateTime.now().subtract(const Duration(hours: 24));
      filtered = filtered.where((place) => place.createdAt.isAfter(yesterday)).toList();
    }

    // Filter by distance (if user location is provided)
    if (distance != null && userLocation != null) {
      final Distance distanceCalc = const Distance();
      filtered = filtered.where((place) {
        final distanceInMeters = distanceCalc(userLocation, place.position);
        return distanceInMeters <= distance * 1000; // Convert km to meters
      }).toList();
    }

    return filtered;
  }
}