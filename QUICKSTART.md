# Quick Start Guide - Clash Royale Flutter App

## Run Web App (Development)

```bash
cd /home/jacky/Desktop/project_v2/clash_royale_flutter

# With API token
flutter run --dart-define=CLASH_ROYALE_API_TOKEN=your_token_here -d chrome

# Or edit lib/config/app_config.dart first, then:
flutter run -d chrome
```

## Run Android App (Development)

```bash
cd /home/jacky/Desktop/project_v2/clash_royale_flutter

# Make sure you have an Android device connected or emulator running
flutter devices

# Run with API token
flutter run --dart-define=CLASH_ROYALE_API_TOKEN=your_token_here

# Or edit lib/config/app_config.dart first, then:
flutter run
```

## Build for Production

### Web
```bash
# Build web release
flutter build web --release --dart-define=CLASH_ROYALE_API_TOKEN=your_token_here

# Output will be in: build/web/
# Deploy this directory to any static hosting service
```

### Android
```bash
# Build APK (for direct installation)
flutter build apk --release --dart-define=CLASH_ROYALE_API_TOKEN=your_token_here

# Output will be in: build/app/outputs/flutter-apk/app-release.apk

# Or build App Bundle (for Google Play Store)
flutter build appbundle --release --dart-define=CLASH_ROYALE_API_TOKEN=your_token_here

# Output will be in: build/app/outputs/bundle/release/app-release.aab
```

## Get Clash Royale API Token

1. Visit: https://developer.clashroyale.com
2. Login or create account
3. Go to "My Account" → "Create New Key"
4. Fill in:
   - Name: Any name
   - Description: Optional
   - IP Address: Your current IP (get from https://whatismyipaddress.com)
5. Copy the generated token

## Configure API Token (Two Methods)

### Method 1: Runtime (Recommended)
Pass token using `--dart-define` flag when running or building (see commands above)

### Method 2: Hardcode (Development Only)
Edit `lib/config/app_config.dart`:
```dart
static String apiToken = 'your_api_token_here';
```

## Project Location

```
/home/jacky/Desktop/project_v2/clash_royale_flutter/
```

## Useful Commands

```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Check for outdated packages
flutter pub outdated

# List available devices
flutter devices
```

## File Structure

```
lib/
├── main.dart              # Entry point
├── config/                # Configuration
├── models/                # Data models
├── services/              # API & business logic
├── providers/             # State management
├── screens/               # Main screens
└── widgets/               # Reusable widgets

assets/
└── emotes/                # Emote images (5 files)
```

## Common Issues

**API Error 403**: Token invalid or IP changed  
**API Error 404**: Player tag incorrect  
**API Error 503**: API temporarily down  
**Build Error**: Run `flutter clean && flutter pub get`

## Testing Example Player Tags

- `#2PP`
- `#Y9UVY82C`

---

For full documentation, see [README.md](README.md)
