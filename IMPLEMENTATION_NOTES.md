# Implementation Notes

## Decisions & Trade-offs

### 1. Firebase Integration (Phase 3)
- **Decision:** Full Firebase integration with mock fallback.
- `firebase_options.dart` configured for project `yogawahyu24` with Android, iOS, macOS, Windows, and Web.
- `AuthProvider` (ChangeNotifier) wraps `FirebaseAuth` + `Firestore` 'users' collection for auth state.
- `FirestoreProvider` (ChangeNotifier) wraps `FirestoreService` for rooms, reports, notifications.
- On Firestore call failure, automatically falls back to `MockDataService` (graceful degradation).
- All screens use `Provider.of<T>()` / `context.watch<T>()` to consume data.

### 2. Authentication
- `LoginScreen` / `SignupScreen` call `AuthProvider.signIn()` / `signUp()` which use real Firebase Auth.
- Error messages map Firebase error codes to Indonesian.
- Splash screen checks `AuthProvider.isLoggedIn` for auto-redirect.

### 3. Navigation Architecture
- **Decision:** `NavShell` uses `IndexedStack` + `BottomNavigationBar` + `Drawer`.
- Routes read `AuthProvider.user` to pass to `NavShell`.
- `NavShell` drawer uses `AuthProvider.signOut()` for logout.

### 4. Design System
- **Decision:** `RumaTheme` extends Material 3 with `GoogleFonts.inter()`.
- Colors: Primary Blue #1A56DB, Secondary Green #10B981, Warning Yellow #F59E0B, Danger Red #EF4444.
- Corner radius: 12px for buttons/inputs, 16px for cards.

### 5. QR Scanning
- Uses `mobile_scanner` package. QR data format: `RUMA:{room_id}`.
- Scanned code resolved through `FirestoreProvider.roomById()` / `roomByQrData()`.

### 6. State Management
- `MultiProvider` at app root with `AuthProvider` + `FirestoreProvider`.
- Screens call `loadAllReports()`, `loadRooms()`, etc. in `initState` via `addPostFrameCallback`.

### 7. Data Flow
- **Dashboard:** reads `FirestoreProvider.rooms` + `allReports` (live after load).
- **Report Issue:** uses `Uuid().v4()` for ID, saves via `FirestoreProvider.addReport()` to `reports` collection.
- **Maintenance History:** filters `userReports` by `AuthProvider.user.uid`.
- **Admin Console:** aggregated stats from `allReports` + `rooms`.
- **Notifications:** loaded per user from `notifications` collection; falls back to mock data.

## Known Issues

1. **Mobile scanner on Windows** — QR scanner requires a physical device or emulator with camera.
2. **Google Fonts** — First load may require internet to download Inter font family.
3. **Firebase on Android** — Requires `google-services.json` and `apply plugin: com.google.gms.google-services` in `android/app/build.gradle.kts`.
4. **Symlink warning** — On Windows, building with plugins may warn about symlink support; enable Developer Mode.
5. **Change Password** — Currently signs out user (Firebase requires re-authentication for password change).
6. **Notifications** — No real-time push; data loaded on page init only (no stream subscription).

## Out of Scope (per SRS)

- Procurement/inventory management
- Multi-campus/branch system
- Discount or payment systems
- Real-time chat/messaging
- Advanced analytics / ML predictions

## Future Scope

- Push notifications via Firebase Cloud Messaging
- Image upload to Firebase Storage for report photos
- Teknisi role with assignment acceptance flow
- In-app chat between reporter and teknisi
- Dark mode support
- Offline support with Firestore cache
- Real-time streams for reports/notifications (Firestore snapshots)
