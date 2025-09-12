// lib/widgets/map_marker.dart
import 'package:flutter/material.dart';
import '../models/place.dart';
import '../styles/app_colors.dart';

class MapMarkerWidget extends StatelessWidget {
  final Place place;
  final bool isSelected;
  final VoidCallback? onTap;

  const MapMarkerWidget({
    super.key,
    required this.place,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSelected ? 40 : 32,
        height: isSelected ? 40 : 32,
        decoration: BoxDecoration(
          color: _getColorForPlaceType(place.type),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _getIconForPlaceType(place.type),
          color: Colors.white,
          size: isSelected ? 20 : 16,
        ),
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
}