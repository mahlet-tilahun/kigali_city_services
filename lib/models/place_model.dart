// This model represents a single listing stored in Firestore.
// It maps to/from a Firestore document using toMap() and fromMap().

import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceModel {
  final String? id; // Firestore document ID (null before first save)
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy; // UID of the user who created this listing
  final DateTime timestamp;

  PlaceModel({
    this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
  });

  // Convert PlaceModel to a Map so we can save it to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create a PlaceModel from a Firestore document snapshot
  factory PlaceModel.fromMap(String id, Map<String, dynamic> map) {
    return PlaceModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      address: map['address'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      description: map['description'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      createdBy: map['createdBy'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  // Create a copy with some fields changed (used during edits)
  PlaceModel copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

// All categories supported by the app
const List<String> kCategories = [
  'All',
  'Hospital',
  'Police Station',
  'Library',
  'Restaurant',
  'Café',
  'Park',
  'Tourist Attraction',
  'Utility Office',
];
