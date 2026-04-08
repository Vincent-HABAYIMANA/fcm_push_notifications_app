# Lab 6 — Push Notifications with Firebase Cloud Messaging (FCM)

## Year 3 CSE | Flutter + Firebase

---

## Project Structure

```
fcm_app/
├── lib/
│   ├── main.dart                  # Full FCM implementation
│   └── firebase_options.dart      # ⚠️ TEMPLATE — replace with real values
├── android/
│   ├── app/
│   │   ├── build.gradle           # Firebase plugin applied here
│   │   ├── google-services.json   # ⚠️ TEMPLATE — replace with real file
│   │   └── src/main/
│   │       └── AndroidManifest.xml
│   └── build.gradle               # Google Services classpath
├── pubspec.yaml                   # Dependencies: firebase_core, firebase_messaging, flutter_local_notifications
├── SETUP_GUIDE.pdf                # Complete step-by-step setup guide
└── HANDWRITTEN_OBSERVATIONS_TEMPLATE.pdf  # Print & fill for submission
```

---

## Quick Start

### 1. Firebase Setup
1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add an Android app with package: `com.example.fcm_app`
3. Download `google-services.json` → place in `android/app/`

### 2. Generate firebase_options.dart
```bash
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
```

### 3. Run
```bash
flutter pub get
flutter run   # on a real device
```

---

## Features Implemented
- ✅ Notification permission request
- ✅ FCM device token displayed on screen
- ✅ Foreground notification handling with popup dialog
- ✅ Background notification handling
- ✅ App launched from terminated state via notification
- ✅ Notification list UI showing received messages
- ✅ Local notification shown via `flutter_local_notifications`

---

## Submission
See **SETUP_GUIDE.pdf** for full instructions and **HANDWRITTEN_OBSERVATIONS_TEMPLATE.pdf** to fill in your observations.
