# FestMap (Flutter)

Mobile app for dropping and viewing festival observation pins on a map. UI follows the React mockup in `../Mockup/` (dark theme, orange accent, slide-up questionnaire).

## Features

- Centers the map on the device GPS location (zoom ~16)
- Shows pins from other users within ~15 km (Firestore realtime stream)
- **Drop Pin** at your current location, or long-press the map to choose a spot
- Questionnaire: Location (autofilled via reverse geocoding), Activity, Size, Movement/Direction, Attire/Style, Date & Time
- No sign-up or sign-in UI — writes go straight to Firestore with open create rules

## Setup

**Bundle / package ID (all platforms):** `com.cultureconnection.festmap.festmap`

### 1. Firebase & Firestore

```bash
cd festmap
dart pub global activate flutterfire_cli
flutterfire configure
```

Copy `google-services.json` into `android/app/` and `GoogleService-Info.plist` into `ios/Runner/`.

Enable **Cloud Firestore** in the Firebase console.

Deploy security rules from the repo root:

```bash
cd ../firebase
firebase deploy --only firestore:rules
```

### 2. Google Maps

1. In Google Cloud Console, enable **Maps SDK for Android** and **Maps SDK for iOS** (same project as Firebase is fine).
2. Create an API key and restrict it to your app IDs.
3. Replace placeholders:
   - Android: `android/app/src/main/AndroidManifest.xml` → `com.google.android.geo.API_KEY`
   - iOS: `ios/Runner/Info.plist` → `GMSApiKey`

### 3. Run

```bash
flutter pub get
flutter run
```

Until `firebase_options.dart` contains your real `projectId` (not `YOUR_PROJECT_ID`), the app shows an in-app setup checklist instead of the map.

## Firestore schema

Collection: `pins`

| Field        | Type     | Description                    |
|-------------|----------|--------------------------------|
| lat, lng    | number   | Pin coordinates                |
| location    | string   | Venue / place label            |
| activity    | string   | Activity / performance         |
| size        | string   | Crowd size / energy            |
| direction   | string   | Movement / direction           |
| attire      | string   | Attire / style                 |
| observedAt  | string   | ISO-8601 local observation time|
| createdAt   | timestamp| Server time at create          |

## Project layout

```
lib/
  main.dart              # Firebase init
  screens/home_screen.dart
  widgets/               # Map, header, form sheet
  services/              # Location, Firestore repository
  models/fest_pin.dart
```
