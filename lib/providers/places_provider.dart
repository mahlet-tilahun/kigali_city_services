// State management layer for place listings.
// Wraps PlacesService and exposes:
//   - allPlaces: real-time list from Firestore
//   - myPlaces: listings created by current user
//   - filtered/searched results
//   - loading and error states
// UI widgets listen to this provider, never calling Firestore directly.

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/places_service.dart';
import '../models/place_model.dart';

class PlacesProvider extends ChangeNotifier {
  final PlacesService _placesService = PlacesService();

  // State variables
  List<PlaceModel> _allPlaces = [];
  List<PlaceModel> _myPlaces = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Subscriptions to Firestore real-time streams
  StreamSubscription<List<PlaceModel>>? _allPlacesSub;
  StreamSubscription<List<PlaceModel>>? _myPlacesSub;

  // Public getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // All places, filtered by current search/category
  List<PlaceModel> get filteredPlaces {
    return _allPlaces.where((place) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          place.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || place.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Current user's listings, filtered by search/category
  List<PlaceModel> get filteredMyPlaces {
    return _myPlaces.where((place) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          place.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || place.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Start listening to Firestore streams.
  /// Called once the user is authenticated.
  void startListening(String uid) {
    // Listen to all places stream
    _allPlacesSub = _placesService.getAllPlaces().listen(
      (places) {
        _allPlaces = places;
        notifyListeners(); // Rebuild Directory + Map screens
      },
      onError: (error) {
        _errorMessage = 'Failed to load places: $error';
        notifyListeners();
      },
    );

    // Listen to this user's places stream
    _myPlacesSub = _placesService
        .getPlacesByUser(uid)
        .listen(
          (places) {
            _myPlaces = places;
            notifyListeners(); // Rebuild My Listings screen
          },
          onError: (error) {
            _errorMessage = 'Failed to load your listings: $error';
            notifyListeners();
          },
        );
  }

  /// Stop listening (called on logout)
  void stopListening() {
    _allPlacesSub?.cancel();
    _myPlacesSub?.cancel();
    _allPlaces = [];
    _myPlaces = [];
    notifyListeners();
  }

  /// Update search query — triggers filteredPlaces to recalculate
  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Update selected category filter
  void updateCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// CREATE a new listing in Firestore
  Future<bool> addPlace(PlaceModel place) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _placesService.addPlace(place);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add listing: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// UPDATE an existing listing in Firestore
  Future<bool> updatePlace(PlaceModel place) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _placesService.updatePlace(place);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update listing: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// DELETE a listing from Firestore
  Future<bool> deletePlace(String placeId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _placesService.deletePlace(placeId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete listing: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _allPlacesSub?.cancel();
    _myPlacesSub?.cancel();
    super.dispose();
  }
}
