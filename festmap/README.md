# FestMap (Flutter)

Cross-platform app (Android, iOS, **web**) for dropping and viewing festival observation pins on a map. One **Firestore** backend for all platforms. UI follows the React mockup in `../Mockup/` (dark theme, orange accent, slide-up questionnaire).

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

Enable in Google Cloud project `festival-tracker-221ca`:

| Platform | API to enable | Where to put the key |
|----------|---------------|----------------------|
| Android | Maps SDK for Android | `android/app/src/main/AndroidManifest.xml` |
| iOS | Maps SDK for iOS | `ios/Runner/Info.plist` → `GMSApiKey` |
| **Web** | **Maps JavaScript API** | `web/index.html` → `<script src="...maps/api/js?key=...">` |
| **Web** (optional) | **Geocoding API** | Same web API key — street addresses in the Location field |

Use your dedicated Maps keys per platform (or the Firebase web key for `index.html` if Maps JavaScript API is enabled on it).

On web, location labels use **Google Geocoding API** when enabled, otherwise **OpenStreetMap Nominatim** (coordinates only if both fail).

### 3. Run

**Mobile:**

```bash
flutter pub get
flutter run
```

**Web (local):**

```bash
flutter run -d chrome
```

Allow **location** when the browser prompts you.

**Web (production build + Firebase Hosting):**

```bash
flutter build web --release
cd ../firebase
firebase deploy --only hosting
```

Hosting serves `festmap/build/web` (SPA rewrite to `index.html`).

**Web (production on Railway):**

Deploy from the **repository root** (parent of `festmap/`). Railway uses the root `Dockerfile` to build Flutter web and serve it.

See **[docs/railway-deploy.md](../docs/railway-deploy.md)** for GitHub deploy steps, custom domains, and Maps API referrer setup.

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
