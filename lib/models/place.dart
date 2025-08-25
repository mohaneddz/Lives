import 'package:latlong2/latlong.dart';

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
  final String id;
  final String name;
  final String description;
  final LatLng position;
  final PlaceType type;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final bool isActive;
  final String? contact;
  final String? address;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
    required this.type,
    required this.verificationStatus,
    required this.createdAt,
    this.isActive = true,
    this.contact,
    this.address,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      position: LatLng(json['latitude'], json['longitude']),
      type: PlaceType.values[json['type']],
      verificationStatus: VerificationStatus.values[json['verificationStatus']],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      contact: json['contact'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'type': type.index,
      'verificationStatus': verificationStatus.index,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'contact': contact,
      'address': address,
    };
  }
}