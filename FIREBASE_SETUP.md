# Firebase Setup Guide — Hunger Point

## Step 1 — Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **Add Project** → name: `hunger-point`
3. Disable Google Analytics → **Create Project**

---

## Step 2 — Enable Phone Authentication

1. Firebase Console → **Authentication** → Get Started
2. Sign-in method tab → **Phone** → Enable → Save

---

## Step 3 — Create Firestore Database

1. Firebase Console → **Firestore Database** → Create database
2. Select **Start in test mode** → Next → Enable

---

## Step 4 — Connect Flutter App

Run in your `hunger_point` project folder:

```bash
# Install FlutterFire CLI (one time)
dart pub global activate flutterfire_cli

# Connect your app
flutterfire configure
```

Select your `hunger-point` project.
Select Android + iOS.
This **replaces** `lib/firebase_options.dart` with the real one.

---

## Step 5 — Android SHA-1 (Required for Phone Auth)

```bash
cd android
./gradlew signingReport
```

Copy the **SHA1** value → Firebase Console → Project Settings (gear icon)
→ Your apps → Android app → Add fingerprint → Save

---

## Step 6 — Run the App

```bash
flutter pub get
flutter run
```

---

## Test Phone Auth

Use Firebase's test numbers (no real SMS needed for testing):
1. Firebase Console → Authentication → Sign-in method → Phone
2. Scroll down → Phone numbers for testing
3. Add: +923001234567 → Code: 123456
4. Use this number in the app during development

---

## Firestore Security Rules (after testing)

Replace test mode rules with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /menu_items/{item} {
      allow read: if true;
      allow write: if false;
    }
    match /orders/{order} {
      allow read, write: if request.auth != null;
    }
  }
}
```
