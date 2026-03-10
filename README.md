# Kigali City Services & Places Directory

A Flutter mobile application that helps Kigali residents locate and navigate to essential public services and leisure locations.

---

## Project Structure

```
kigali_city_services/
├── lib/
│   ├── main.dart                        # App entry point, Firebase init, AuthWrapper
│   ├── firebase_options.dart            # Auto-generated Firebase config (FlutterFire CLI)
│   ├── models/
│   │   ├── place_model.dart             # Data model for a place listing
│   │   └── user_model.dart              # Data model for a user profile
│   ├── services/
│   │   ├── auth_service.dart            # All Firebase Auth calls (signup, login, logout)
│   │   └── places_service.dart          # All Firestore CRUD operations
│   ├── providers/
│   │   ├── auth_provider.dart           # Auth state management (Provider)
│   │   └── places_provider.dart         # Listings state, search, filter, CRUD
│   ├── screens/
│   │   ├── main_screen.dart             # Bottom navigation shell
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── verify_email_screen.dart
│   │   ├── directory/
│   │   │   ├── directory_screen.dart        # Browse all listings
│   │   │   ├── detail_screen.dart           # Listing detail + embedded map
│   │   │   └── add_edit_listing_screen.dart
│   │   ├── listings/
│   │   │   └── my_listings_screen.dart      # Current user's listings only
│   │   ├── map/
│   │   │   └── map_view_screen.dart         # All listings as map markers
│   │   └── settings/
│   │       └── settings_screen.dart         # Profile + notification toggle
│   └── widgets/
│       └── place_card.dart              # Reusable listing card component
├── pubspec.yaml                         # Dependencies
└── README.md
```

---

## Features

- **Firebase Authentication** — Email/password signup, login, logout, and enforced email verification before app access
- **Cloud Firestore CRUD** — Create, Read, Update, Delete place listings with real-time updates across all screens
- **Search & Filter** — Search listings by name and filter by category with instant client-side results
- **Map Integration** — Embedded Google Map on detail pages with markers from stored Firestore coordinates; "Get Directions" launches Google Maps navigation
- **Map View** — Full-screen map showing all listings as interactive markers
- **State Management** — Provider pattern with service/provider/UI separation
- **Bottom Navigation** — Directory, My Listings, Map View, Settings

---

## Firestore Database Structure

### /users/{uid}

| Field                | Type    | Description                             |
| -------------------- | ------- | --------------------------------------- |
| uid                  | string  | Firebase Auth UID (matches document ID) |
| email                | string  | User email address                      |
| displayName          | string  | Full name from registration             |
| notificationsEnabled | boolean | Location notification preference        |

### /places/{docId}

| Field         | Type      | Description                                                                                      |
| ------------- | --------- | ------------------------------------------------------------------------------------------------ |
| name          | string    | Place or service name                                                                            |
| category      | string    | Hospital, Police Station, Library, Restaurant, Café, Park, Tourist Attraction, or Utility Office |
| address       | string    | Physical address                                                                                 |
| contactNumber | string    | Phone number                                                                                     |
| description   | string    | Details about the place                                                                          |
| latitude      | number    | Geographic latitude                                                                              |
| longitude     | number    | Geographic longitude                                                                             |
| createdBy     | string    | UID of the user who created the listing                                                          |
| timestamp     | timestamp | Creation time                                                                                    |

---

## State Management Approach

This app uses the **Provider** package with a three-layer architecture:

1. **Service Layer** (`lib/services/`) — The only layer that calls Firebase APIs. `auth_service.dart` handles all Firebase Auth operations. `places_service.dart` handles all Firestore CRUD and real-time streams.

2. **Provider Layer** (`lib/providers/`) — Wraps the services and exposes state to the UI. `AuthProvider` manages authentication state, loading, and error handling. `PlacesProvider` manages listing data, search/filter state, and CRUD operations. Both extend `ChangeNotifier` and call `notifyListeners()` to trigger UI rebuilds.

3. **UI Layer** (`lib/screens/`, `lib/widgets/`) — Reads from providers using `context.watch<T>()` and triggers actions using `context.read<T>()`. Never calls Firebase directly.

---

## Navigation Structure

| Tab | Screen      | Description                                         |
| --- | ----------- | --------------------------------------------------- |
| 1   | Directory   | Browse all listings with search and category filter |
| 2   | My Listings | View, edit, and delete your own listings            |
| 3   | Map View    | All listings as markers on a Google Map             |
| 4   | Settings    | User profile and notification toggle                |

---

## Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /places/{placeId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.createdBy;
    }
  }
}
```

---

## Setup Instructions

1. Clone this repository
2. Run `flutter pub get`
3. Add your own `lib/firebase_options.dart` by running `flutterfire configure` with your Firebase project
4. Add your Google Maps API key to `android/app/src/main/AndroidManifest.xml`
5. Run `flutter run`

---

**Note:** Firebase configuration files are included for demonstration and assessment purposes. All API keys are restricted to this application.
