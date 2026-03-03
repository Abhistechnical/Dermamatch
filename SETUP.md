# DermaMatch AI — Setup Guide

## Project Structure

```
dermamatch-ai/
├── flutter_app/        ← Mobile app (Android & iOS)
└── color_engine/       ← Python FastAPI microservice
```

---

## Step 1: Supabase Setup

1. Sign up at [supabase.com](https://supabase.com) → Create a new project
2. Go to **SQL Editor** → paste the entire contents of `color_engine/database.sql` → Run
3. Go to **Settings → API** and copy:
   - `Project URL` → `SUPABASE_URL`
   - `anon public` key → `SUPABASE_ANON_KEY`

---

## Step 2: Razorpay Sandbox

1. Sign up at [dashboard.razorpay.com](https://dashboard.razorpay.com)
2. Go to **Settings → API Keys → Test Mode**
3. Generate a key pair and copy:
   - `Key ID` → `RAZORPAY_KEY_ID`
   - `Key Secret` → `RAZORPAY_KEY_SECRET`

---

## Step 3: Configure Flutter Environment

```bash
cd flutter_app
cp .env.example .env
# Edit .env and fill in all keys
```

**Edit `.env`:**
```env
SUPABASE_URL=https://yourproject.supabase.co
SUPABASE_ANON_KEY=your_anon_key
COLOR_ENGINE_URL=http://10.0.2.2:8000   # Android emulator → localhost
# COLOR_ENGINE_URL=http://localhost:8000  # iOS simulator
RAZORPAY_KEY_ID=rzp_test_xxxxx
RAZORPAY_KEY_SECRET=xxxxx
API_KEY=any_secret_for_b2b
```

> `10.0.2.2` is Android emulator's alias for `localhost` on your PC.
> For iOS simulator, use `localhost:8000`.
> For physical device, use your machine's local IP e.g. `192.168.1.100:8000`.

---

## Step 4: Android Permissions

In `android/app/src/main/AndroidManifest.xml`, add inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

Also add the Razorpay activity inside `<application>`:
```xml
<activity
    android:name="com.razorpay.CheckoutActivity"
    android:configChanges="keyboard|keyboardHidden|orientation|screenSize"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
```

---

## Step 5: iOS Permissions

In `ios/Runner/Info.plist`, add:
```xml
<key>NSCameraUsageDescription</key>
<string>DermaMatch needs camera access to take your skin tone photo.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>DermaMatch needs gallery access to select your photo.</string>
```

---

## Step 6: Run Python Color Engine

```bash
cd color_engine

# Create virtual environment
python -m venv venv
venv\Scripts\activate         # Windows
# source venv/bin/activate    # macOS/Linux

# Install dependencies
pip install -r requirements.txt

# Start the server (binds to 0.0.0.0 so phones can connect over WiFi)
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Test it: open [http://localhost:8000/docs](http://localhost:8000/docs)

---

## Step 7: Run Flutter App

```bash
cd flutter_app

# Install packages
flutter pub get

# Run on connected device / emulator
flutter run
```

---

## Color Engine API

### `POST /analyze`

Accepts: `multipart/form-data` with field `file` (image)

**Sample Response:**
```json
{
  "depth": "Medium",
  "undertone": "Warm",
  "raw_rgb": {"r": 185, "g": 140, "b": 110},
  "corrected_rgb": {"r": 183, "g": 138, "b": 108},
  "hex": "#B78A6C",
  "cmyk": {"c": 0.0, "m": 24.6, "y": 41.0, "k": 28.2},
  "ryb": {"r": 183, "y": 142, "b": 34},
  "pigment_mix": {
    "yellow": 32.4,
    "red": 22.9,
    "blue": 3.4,
    "white": 30.1,
    "black": 11.2
  },
  "recommended_shades": [
    "Caramel Drizzle",
    "Warm Almond",
    "Honey Wheat"
  ]
}
```

### `GET /health`
Returns `{"status": "ok"}` — use for uptime checks.

---

## Production Deployment

| Service | Option |
|---|---|
| Color Engine | Railway, Render, Fly.io (Docker) |
| Database | Supabase (already hosted) |
| Flutter | Play Store + App Store |

**Note:** Change `allow_origins=["*"]` in `main.py` to your production domain before release.

---

## Architecture Diagram

```
Flutter App (Android/iOS)
    │
    ├── Supabase Auth (signup/login)
    ├── Supabase DB (scan history, credits)
    ├── Razorpay (credit purchase)
    └── POST /analyze ──→ Python FastAPI Color Engine
                              │
                              ├── MediaPipe FaceMesh (face detection)
                              ├── OpenCV (lighting correction)
                              ├── Color Engine (HEX/CMYK/RYB/Pigment)
                              └── Shade Recommender (52-shade LAB DB)
```
