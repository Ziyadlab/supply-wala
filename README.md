# Supply Wala

Supply Wala is a Flutter Final Year Project prototype for a B2B marketplace that connects restaurants with suppliers.

## Features

- Splash, onboarding, login, signup, forgot password, role selection, validation, and logout
- Role-based navigation for Restaurant and Supplier users
- Restaurant supplier marketplace with search, category/location/rating filters, supplier profiles, inventory, cart, checkout, order history, and chat
- Simulated voice-to-cart assistant with confirmation modal and editable recognized items
- Firebase Auth for Android using `android/app/google-services.json`, with web/desktop demo fallback
- Real speech-to-text voice capture where supported, with simulated fallback for demos
- Supplier dashboard with total, pending, completed, and inventory counts
- Supplier inventory add, edit, delete, availability, and order status management
- Chat list/detail UI, profile, and edit profile screens
- In-memory sample data structured for later Firebase, Supabase, or custom API integration

## Project Structure

```text
lib/
  app.dart
  main.dart
  core/
    app_theme.dart
  data/
    sample_data.dart
  models/
    app_models.dart
  state/
    app_state.dart
  widgets/
    app_widgets.dart
  screens/
    auth/
    restaurant/
    supplier/
    shared/
```

## Run

```bash
flutter pub get
flutter run
```

Useful demo credentials:

- Restaurant: `restaurant@supplywala.pk` / `123456`
- Supplier: choose Supplier role and use any valid email plus `123456`

## Notes

Firebase Auth is active on Android when the SDK is configured and your Firebase project has Email/Password auth enabled. Chrome/web keeps a demo fallback unless you add web Firebase options.

The voice assistant first tries device speech recognition through `speech_to_text`. If speech is unavailable, it falls back to a demo transcript so the cart flow still works during presentations.
