# RUMA (Room Utility Management Assistant)

A smart campus facility management system built with Flutter and Firebase.

## Features

- **Dashboard** — Campus Health Score overview, room list, latest reports
- **Scan QR** — Scan room QR codes to view details and report issues
- **Report Issue** — Submit maintenance reports (AC, Lampu, Listrik, etc.)
- **Maintenance History** — Track and filter all submitted reports
- **Notifications** — Real-time updates on report status changes
- **Admin Console** — Overview stats, report management, room monitoring
- **Profile** — User info, change password, logout

## Tech Stack

- **Frontend:** Flutter 3.41+ / Dart 3.11+
- **Backend:** Firebase Auth, Cloud Firestore, Firebase Storage
- **State Management:** Provider
- **Fonts:** Inter (Google Fonts)

## Installation

### Prerequisites

- Flutter SDK 3.41+ ([install guide](https://docs.flutter.dev/get-started/install))
- Firebase project with Auth, Firestore, and Storage enabled
- Android Studio / Xcode / VS Code

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/anomalyco/ruma_app.git
cd ruma_app

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
# Place your firebase_options.dart in lib/config/
# Or use the Firebase CLI:
#   dart pub global activate flutterfire_cli
#   flutterfire configure

# 4. Run the app
flutter run
```

### Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Mahasiswa | mahasiswa@ruma.ac.id | password123 |
| Admin | admin@ruma.ac.id | password123 |

> The prototype uses mock data. Firebase integration is pre-wired — swap mock data with Firestore calls once Firebase is configured.

## Project Structure

```
lib/
├── config/
│   ├── theme.dart             # Design system (colors, typography, components)
│   └── routes.dart            # Route definitions and navigation
├── models/
│   ├── user_model.dart        # User data model
│   ├── room_model.dart        # Room data model
│   ├── report_model.dart      # Report data model
│   └── notification_model.dart # Notification data model
├── services/
│   ├── auth_service.dart      # Firebase Authentication wrapper
│   ├── firestore_service.dart  # Cloud Firestore operations
│   └── mock_data_service.dart  # Mock data for prototype
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── dashboard_screen.dart
│   ├── scan_qr_screen.dart
│   ├── room_detail_screen.dart
│   ├── report_issue_screen.dart
│   ├── report_detail_screen.dart
│   ├── maintenance_history_screen.dart
│   ├── notifications_screen.dart
│   ├── profile_screen.dart
│   └── admin_console_screen.dart
├── widgets/
│   ├── nav_shell.dart          # Bottom navigation + drawer
│   ├── health_score_card.dart  # Campus Health Score card
│   ├── status_badge.dart       # Status indicator badge
│   ├── report_card.dart        # Report list item card
│   ├── empty_state.dart        # Empty state placeholder
│   └── loading_state.dart      # Loading indicator
└── main.dart                   # App entry point
```

## Login Flow

1. App opens → **Splash Screen** (2s) → **Login Screen**
2. Enter email + password (or use demo credentials)
3. → **Dashboard** (with bottom nav: Beranda, Scan QR, Riwayat, Notifikasi)
4. Pull drawer or tap profile icon → Profile / Notifikasi / Admin / Logout

## Report Issue Flow (UC-003)

1. **Scan QR** (tap Scan QR tab) → camera scans room QR code
2. → **Room Detail** screen shows health score, info, history
3. Tap **Laporkan Masalah** → select category, priority, write description
4. Submit → success toast → back to room detail
5. Report appears in **Riwayat** and **Dashboard**

## Admin Flow

1. Tap drawer → **Admin Console** (or login as admin@ruma.ac.id)
2. Tabs: Overview (stats + category distribution), Laporan (all reports), Ruangan (all rooms)
3. Tap any report to view details

## Testing

```bash
flutter test
```

## Reset

To reset mock data, restart the app. No persistent storage is used in prototype mode.
