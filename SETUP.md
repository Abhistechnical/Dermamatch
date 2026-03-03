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

## Step 8: Amazon Affiliate Monetization

1. Open your Supabase **SQL Editor**.
2. Run the script: `color_engine/affiliate_setup.sql`.
   - This creates `foundation_products` and `affiliate_clicks` tables.
   - It also inserts sample high-converting foundation data.

---

## Production Deployment (Railway.app)

1. Sign up at [Railway.app](https://railway.app) using GitHub.
2. Click **New Project** → **Deploy from GitHub repo**.
3. Select your `Dermamatch` repository.
4. **Important**: In the service settings, set the **Root Directory** to `color_engine`.
5. Go to **Variables** and add:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `API_KEY`
6. Railway will automatically detect the `Procfile` and deploy your backend.
7. Copy the generated `.up.railway.app` URL.
8. Update `flutter_app/.env` → `COLOR_ENGINE_URL=https://your-app.up.railway.app`.

---

## Architecture Diagram

```
Flutter App (Android/iOS)
    │
    ├── Supabase Auth (signup/login)
    ├── Supabase DB (scan history, affiliate clicks)
    ├── Razorpay (credit purchase)
    └── POST /analyze ──→ Python FastAPI Color Engine (Railway)
                               │
                               ├── MediaPipe FaceMesh (detection)
                               ├── OpenCV (lighting/color)
                               └── Shade Recommender (Amazon Affiliates)
```
