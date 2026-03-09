// lib/screens/directory/directory_screen.dart
// Shows all listings from Firestore.
// Users can search by name and filter by category.
// Updates automatically whenever Firestore data changes (via PlacesProvider stream).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/places_provider.dart';
import '../../models/place_model.dart';
import '../../widgets/place_card.dart';
import 'add_edit_listing_screen.dart';
import 'detail_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final placesProvider = context.watch<PlacesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali City Directory'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: placesProvider.updateSearch,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: kCategories.length,
              itemBuilder: (context, index) {
                final cat = kCategories[index];
                final isSelected = placesProvider.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => placesProvider.updateCategory(cat),
                    selectedColor: Colors.amber,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Listings list
          Expanded(
            child: placesProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : placesProvider.filteredPlaces.isEmpty
                    ? const Center(child: Text('No listings found.'))
                    : ListView.builder(
                        itemCount: placesProvider.filteredPlaces.length,
                        itemBuilder: (context, index) {
                          final place = placesProvider.filteredPlaces[index];
                          return PlaceCard(
                            place: place,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DetailScreen(place: place)),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      // FAB to add a new listing
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
