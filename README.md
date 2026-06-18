# Finance Manager Mobile

Flutter mobile app for Finance Manager.

## Stack

- **Flutter** + Dart
- **Provider** for state management
- **Dio** for HTTP
- **flutter_secure_storage** for JWT token storage
- Material 3 design

## Getting started

```bash
# Install Flutter: https://docs.flutter.dev/get-started/install
flutter pub get

# Run on Android emulator or connected device
flutter run

# Run with custom API URL (use your machine's local IP)
flutter run --dart-define=API_URL=http://192.168.1.X:8080/api
```

## Screens

| Screen | Description |
|--------|-------------|
| Login | Sign in |
| Register | Create account |
| Dashboard | Balance overview + recent transactions (pull to refresh) |
| Accounts | Manage accounts (swipe to delete) |
| Transactions | Add / view transactions (swipe to delete) |
