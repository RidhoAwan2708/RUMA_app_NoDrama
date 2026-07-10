# Implementation Notes

## Decisions & Trade-offs

### 1. Mock Data Layer
- **Decision:** All screens use `MockDataService` instead of live Firestore calls.
- **Rationale:** The prototype must be immediately runnable without requiring Firebase project setup.
- **Path forward:** Swap `MockDataService.mockRooms` / `mockReports` / `mockNotifications` with `FirestoreService` calls when Firebase is configured.

### 2. Authentication
- **Decision:** Login screen validates locally; no real Firebase Auth check.
- **Rationale:** Avoid dependency on Firebase configuration for demo.

### 3. Navigation Architecture
- **Decision:** `NavShell` uses `IndexedStack` + `BottomNavigationBar` + `Drawer`.
- **Rationale:** Matches typical campus app UX with persistent bottom nav and profile drawer.
- `NavShell` is instantiated twice in routing (for civitas and admin) with different destination sets.

### 4. Design System
- **Decision:** `RumaTheme` extends Material 3 with `GoogleFonts.inter()`.
- **Colors:** Primary Blue #1A56DB, Secondary Green #10B981, Warning Yellow #F59E0B, Danger Red #EF4444.
- **Corner radius:** 12px for buttons/inputs, 16px for cards.
- **Font:** Inter (via google_fonts package).

### 5. QR Scanning
- **Decision:** Uses `mobile_scanner` package (actively maintained).
- **Fallback:** QR code data format: `RUMA:{room_id}`.

### 6. State Management
- **Decision:** Provider is declared as dependency but not used extensively (prototype scope).
- **Path forward:** Implement `AuthProvider` and `ReportProvider` for real state management.

### 7. Firebase Configuration
- **Decision:** `firebase_options.dart` is not included (requires Firebase CLI setup per project).
- **To configure:** Run `flutterfire configure` in the project root.

## Known Issues

1. **Mobile scanner on Windows** — QR scanner requires a physical device or emulator with camera.
2. **Google Fonts** — First load may require internet to download Inter font family.
3. **Firebase on Android** — May need `google-services.json` and `apply plugin: com.google.gms.google-services` in `android/app/build.gradle`.
4. **Symlink warning** — On Windows, building with plugins may warn about symlink support; enable Developer Mode.

## Out of Scope (per SRS)

- Procurement/inventory management
- Multi-campus/branch system
- Discount or payment systems
- Real-time chat/messaging
- Advanced analytics / ML predictions

## Future Scope

- Live Firestore integration (auth, reports, notifications)
- Push notifications via Firebase Cloud Messaging
- Image upload to Firebase Storage for report photos
- Teknisi role with assignment acceptance flow
- In-app chat between reporter and teknisi
- Dark mode support
- Offline support with Firestore cache
