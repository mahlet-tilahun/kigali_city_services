// This service handles all Firestore CRUD operations for place listings.
// UI widgets don't call Firestore directly, they go through this service.
// The provider layer then wraps this service and exposes state to the UI.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place_model.dart';

class PlacesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to the 'places' collection in Firestore
  CollectionReference get _placesRef => _firestore.collection('places');

  /// Returns a real-time stream of ALL place listings.
  /// Using snapshots() means Firestore pushes updates automatically —
  /// no need to manually refresh the screen.
  Stream<List<PlaceModel>> getAllPlaces() {
    return _placesRef.orderBy('timestamp', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return PlaceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Returns a real-time stream of places created by a specific user.
  /// Used in the "My Listings" screen.
  Stream<List<PlaceModel>> getPlacesByUser(String uid) {
    return _placesRef
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PlaceModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  /// CREATE: Add a new place listing to Firestore.
  /// Firestore auto-generates the document ID.
  Future<void> addPlace(PlaceModel place) async {
    await _placesRef.add(place.toMap());
  }

  /// UPDATE: Edit an existing place listing.
  /// Only the owner can do this (enforced in the UI layer too).
  Future<void> updatePlace(PlaceModel place) async {
    await _placesRef.doc(place.id).update(place.toMap());
  }

  /// DELETE: Remove a place listing.
  /// Only the owner can delete their own listing.
  Future<void> deletePlace(String placeId) async {
    await _placesRef.doc(placeId).delete();
  }
}
