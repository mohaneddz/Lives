# Lives

Lives is a humanitarian mobile app — in its own words, "made to help our brothers in gaza, with map based utilities." It's built with Flutter and combines a map-based interface with a two-sided user system: regular **Users** and **Contributors** (Individual or Association), the latter requiring identity/registration document upload and admin verification.

## Features

- Map page with live location marker and geolocation (`flutter_map` + `geolocator`)
- Full authentication and registration flow, backed by a real HTTP API:
  - User and Contributor (Individual/Association) registration
  - Email verification via 6-digit code with resend/countdown
  - Form validation, loading/error states, BLoC-based state management (`lib/bloc/auth/`)
- Drawer-based navigation with an integrated Account page driving the auth flow
- Custom app icon and splash screen across Android, iOS, web, Windows, and macOS

## What's simulated / not finished

- Document and ID upload during Contributor registration is **simulated, not real** — both the Individual and Association contributor forms have open TODOs for a real image/document picker
- No persistent session storage yet (user has to re-authenticate; `shared_preferences` / `flutter_secure_storage` are present as dependencies but not fully wired for this)
- No logout implemented
- No admin dashboard for contributor verification (called out in `AUTHENTICATION_README.md` as a separate project)
- Map-based utilities beyond basic location display (the actual humanitarian use case) are not verified beyond a basic map page

## Tech stack

Flutter · Dart (SDK ^3.8.1) · `flutter_bloc` + `equatable` · `flutter_map` + `latlong2` + `geolocator` + `flutter_map_location_marker` · `http` · `shared_preferences` · `flutter_secure_storage` · `google_fonts` · `lucide_icons`

## Status

Hackathon project with a genuinely built-out auth flow, wired to a real backend. Not production-ready — see "What's simulated / not finished" above and `AUTHENTICATION_README.md`'s own "Next Steps for Production" list.

## Getting started

```bash
flutter pub get
flutter run
```

See `AUTHENTICATION_README.md` for the full authentication system spec and status.
