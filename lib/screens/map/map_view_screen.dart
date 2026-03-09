// Shows all listings as markers on a Google Map.
// Tapping a marker navigates to the detail screen of that listing.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/places_provider.dart';
import '../../models/place_model.dart';
import '../directory/detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;

  // Kigali city center coordinates
  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);

  /// Build a set of markers from the places list.
  /// Each marker shows the place name on tap.
  Set<Marker> _buildMarkers(List<PlaceModel> places, BuildContext context) {
    return places.map((place) {
      return Marker(
        markerId: MarkerId(place.id ?? place.name),
        position: LatLng(place.latitude, place.longitude),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.category,
          // Tapping the info window opens the detail screen
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(place: place)),
          ),
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final placesProvider = context.watch<PlacesProvider>();
    // Use filtered places so map respects active search/filter
    final places = placesProvider.filteredPlaces;

    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: const CameraPosition(
          target: _kigaliCenter,
          zoom: 13,
        ),
        markers: _buildMarkers(places, context),
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}
