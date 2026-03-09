// lib/screens/listings/my_listings_screen.dart
// Shows only the listings created by the currently authenticated user.
// Allows editing and deleting. Edit/Delete buttons only appear here.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';
import '../../models/place_model.dart';
import '../../widgets/place_card.dart';
import '../directory/add_edit_listing_screen.dart';
import '../directory/detail_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  /// Show a confirmation dialog then delete the listing
  void _confirmDelete(BuildContext context, PlaceModel place) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text('Are you sure you want to delete "${place.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final success = await context
                  .read<PlacesProvider>()
                  .deletePlace(place.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        success ? 'Listing deleted' : 'Failed to delete'),
                    backgroundColor:
                        success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final placesProvider = context.watch<PlacesProvider>();
    final authProvider = context.watch<AuthProvider>();
    final myPlaces = placesProvider.filteredMyPlaces;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Listings (${myPlaces.length})',
        ),
      ),
      body: placesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : myPlaces.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('You have no listings yet.',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: myPlaces.length,
                  itemBuilder: (context, index) {
                    final place = myPlaces[index];
                    return PlaceCard(
                      place: place,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => DetailScreen(place: place)),
                      ),
                      // Show edit/delete actions only in My Listings
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blue),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddEditListingScreen(place: place),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () =>
                                _confirmDelete(context, place),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditListingScreen()),
        ),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}
