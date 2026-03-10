// Reusable card widget for displaying a place listing in a list.
// Used by both DirectoryScreen and MyListingsScreen.
// Accepts optional 'trailing' widget (for edit/delete buttons in My Listings).

import 'package:flutter/material.dart';
import '../../../models/place_model.dart';

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onTap;
  final Widget? trailing; // Optional: edit/delete buttons

  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    this.trailing,
  });

  // Returns an icon for each category
  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Hospital':
        return Icons.local_hospital;
      case 'Police Station':
        return Icons.local_police;
      case 'Library':
        return Icons.local_library;
      case 'Restaurant':
        return Icons.restaurant;
      case 'Café':
        return Icons.coffee;
      case 'Park':
        return Icons.park;
      case 'Tourist Attraction':
        return Icons.photo_camera;
      case 'Utility Office':
        return Icons.electric_bolt;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1A2B4A),
          child: Icon(
            _categoryIcon(place.category),
            color: Colors.amber,
            size: 20,
          ),
        ),
        title: Text(
          place.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.category,
              style: const TextStyle(color: Colors.amber, fontSize: 12),
            ),
            Text(
              place.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }
}
