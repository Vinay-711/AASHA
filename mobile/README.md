# AASHA Flutter Client

Flutter source for medication, pharmacy, family/guardian and safety workflow demonstrations. This directory includes application screens, Bloc state handling and platform scaffolding. It is separate from the root browser demonstration and Python backend.

## Development

From `mobile`, use a Flutter SDK compatible with [pubspec.yaml](pubspec.yaml):

```sh
flutter pub get
flutter analyze
flutter run
```

Select an emulator or device supported by your installed Flutter toolchain. Review [lib/firebase_options.dart](lib/firebase_options.dart) and [lib/config/constants.dart](lib/config/constants.dart) before connecting external services; use your own development configuration and synthetic records.

## Code map

- [lib/main.dart](lib/main.dart): application entry point.
- [lib/presentation](lib/presentation): pages, widgets and Bloc state handling.
- [lib/core](lib/core): shared utilities and errors.
- [pubspec.yaml](pubspec.yaml): SDK constraints, dependencies, fonts and assets.

Run device-level checks for navigation, denied camera permissions, offline behavior and failed API requests. No mobile build or clinical evaluation is claimed by this documentation update. Recognition, medication guidance and emergency behavior remain prototype capabilities requiring human confirmation. See the [root README](../README.md) for scope and the separately tested pharmacy backend.
