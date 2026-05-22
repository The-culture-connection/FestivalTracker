# Deploy FestMap web on Railway

FestMap’s **web** app is a static Flutter build. Railway runs a multi-stage **Docker** image: Flutter compiles `festmap/build/web`, then **serve** hosts it with SPA routing (`index.html` for unknown paths). **Firestore and Firebase** stay on your existing Firebase project — only hosting moves to Railway.

## Prerequisites

- GitHub repo with this project pushed
- [Railway](https://railway.com) account
- Firebase project already configured (`festmap/lib/firebase_options.dart` from `flutterfire configure`)
- Google Cloud APIs enabled for the **web** Maps key in `festmap/web/index.html`:
  - **Maps JavaScript API** (required)
  - **Geocoding API** (optional, for addresses)

## Option A — Deploy from GitHub (recommended)

1. Open [railway.com/new](https://railway.com/new) → **Deploy from GitHub repo**.
2. Select this repository.
3. **Root directory:** leave as **repository root** (the `Dockerfile` is at the top level).
4. Railway should detect `railway.toml` and use the Dockerfile builder.
5. Click **Deploy** and wait for the build (Flutter web builds often take **5–15 minutes** on the first deploy).
6. Open **Settings → Networking → Generate domain** to get a `*.up.railway.app` URL.

No start command is required — the image listens on Railway’s `PORT` automatically.

## Option B — Railway CLI

```bash
npm i -g @railway/cli
railway login
cd path/to/FestivalApp
railway init
railway up
```

Then generate a public URL in the dashboard (**Networking**).

## After deploy — Google Maps key

Restrict your **browser** Maps/Geocoding API key in [Google Cloud Console](https://console.cloud.google.com/apis/credentials):

1. Edit the key used in `festmap/web/index.html`.
2. **Application restrictions** → **HTTP referrers**.
3. Add:
   - `https://YOUR-SERVICE.up.railway.app/*`
   - `https://your-custom-domain.com/*` (if you add one)

Without this, the map may show a blank tile or `REQUEST_DENIED` in the browser console.

## Custom domain

1. Railway service → **Settings** → **Networking** → **Custom Domain**.
2. Add your domain; Railway shows a **CNAME** target.
3. Create that CNAME at your DNS provider.
4. Add the custom domain to the Maps API key referrers (above).

## Firebase (optional)

If you later add **Firebase Auth** or other domain-restricted features, add your Railway hostname under Firebase Console → **Authentication** → **Settings** → **Authorized domains**.

Firestore reads/writes from the web app do not require a hosting change.

## Local test (same image as Railway)

From the repo root:

```bash
docker build -t festmap-web .
docker run --rm -p 8080:8080 -e PORT=8080 festmap-web
```

Open http://localhost:8080

## Build failures

| Issue | What to do |
|-------|------------|
| Build runs out of memory | In Railway, try a larger build plan or build locally (`flutter build web --release`) and switch to a pre-built static image (contact maintainer / custom Dockerfile). |
| `flutter pub get` fails | Ensure `festmap/pubspec.lock` is committed. |
| Map blank on Railway URL | Add Railway URL to Maps API **HTTP referrer** restrictions. |
| Location timeout on desktop | Expected on some browsers; long-press the map to drop a pin. |

## Firebase Hosting vs Railway

| | Firebase Hosting | Railway |
|--|------------------|---------|
| Build | Local `flutter build web` | Docker build on deploy |
| Cost | Spark/free tier for static | Railway usage-based |
| SPA rewrite | `firebase.json` rewrites | `serve -s` |
| Backend | Same Firestore | Same Firestore |

You can keep Firebase for **Firestore rules** and stop using `firebase deploy --only hosting` if Railway is your only web host.

## Files

| File | Role |
|------|------|
| `Dockerfile` | Flutter build + `serve` static host |
| `railway.toml` | Dockerfile builder + health check |
| `.dockerignore` | Smaller, faster Docker context |
