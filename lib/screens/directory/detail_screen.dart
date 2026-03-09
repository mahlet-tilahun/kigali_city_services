// lib/screens/directory/detail_screen.dart
// Shows full details of a selected listing.
// Includes an embedded Google Map with a marker.
// Has a "Get Directions" button that opens Google Maps for navigation.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/place_model.dart';

class DetailScreen extends StatefulWidget {
  final PlaceModel place;

  const DetailScreen({super.key, required this.place});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  GoogleMapController? _mapController;

  // Build a marker set for the place's coordinates
  Set<Marker> get _markers => {
        Marker(
          markerId: const MarkerId('place'),
          position: LatLng(widget.place.latitude, widget.place.longitude),
          infoWindow: InfoWindow(title: widget.place.name),
        ),
      };

  /// Open Google Maps with turn-by-turn directions to this location
  Future<void> _launchDirections() async {
    final lat = widget.place.latitude;
    final lng = widget.place.longitude;
    final name = Uri.encodeComponent(widget.place.name);
    // This URL opens Google Maps with the destination pre-filled
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$name&travelmode=driving';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Embedded Google Map (250px tall)
            SizedBox(
              height: 250,
              child: GoogleMap(
                onMapCreated: (controller) => _mapController = controller,
                initialCameraPosition: CameraPosition(
                  target: LatLng(place.latitude, place.longitude),
                  zoom: 15,
                ),
                markers: _markers,
                myLocationButtonEnabled: false,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      place.category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(
                    place.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Address
                  _infoRow(Icons.location_on, place.address),
                  const SizedBox(height: 6),

                  // Contact
                  _infoRow(Icons.phone, place.contactNumber),
                  const SizedBox(height: 6),

                  // Coordinates
                  _infoRow(Icons.gps_fixed,
                      '${place.latitude}, ${place.longitude}'),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'About',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(place.description,
                      style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 24),

                  // Get Directions button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _launchDirections,
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}
