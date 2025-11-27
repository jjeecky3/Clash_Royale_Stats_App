# ⚔️ Clash Royale Stats & Roast - Flutter App

A cross-platform Flutter application that fetches player statistics from the Clash Royale API and provides entertaining roasts based on performance metrics! Available for Web and Android.

## ✨ Features

- 🎮 **Real-time Stats**: Fetch live player data from the official Clash Royale API
- 📊 **Detailed Analytics**: Win rate, trophy count, card levels, and battle history
- 🔥 **Humorous Roasts**: Get roasted based on your performance (all in good fun!)
- 🎨 **Premium Design**: Modern UI with Clash Royale themed colors, animations, and gradients
- 📱 **Cross-Platform**: Runs on Web and Android
- 🌐 **Responsive**: Works beautifully on all screen sizes

## 🚀 Setup Instructions

### Prerequisites

- Flutter SDK (3.38.3 or higher)
- For Android: Android Studio with Android SDK
- For Web: Chrome browser
- Clash Royale API token

### 1. Get Your API Token

1. Visit [https://developer.clashroyale.com](https://developer.clashroyale.com)
2. Create an account (or login)
3. Go to "My Account" → "Create New Key"
4. Enter:
   - **Name**: Any name (e.g., "Flutter Stats App")
   - **Description**: Optional
   - **IP Address**: Your current IP address (find it at https://whatismyipaddress.com)
5. Click "Create Key" and copy your API token

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Start the Backend Server (For Web Development)

The backend server is required for web development to bypass CORS restrictions.

```bash
cd server
dart run bin/server.dart
```

You should see:
```
🚀 Clash Royale API Proxy Server running on http://localhost:3000
📡 Forwarding requests to Clash Royale API
```

> [!NOTE]
> The server is **only needed for web development**. Android builds work without it.

### 4. Configure API Token

You have two options:

**Option 1: Using dart-define (Recommended for production)**

Run the app with your API token:

```bash
flutter run --dart-define=CLASH_ROYALE_API_TOKEN=your_api_token_here -d chrome
```

**Option 2: Hardcode in config (For development only)**

Edit `lib/config/app_config.dart` and replace the apiToken value:

```dart
static String apiToken = 'your_api_token_here';
```

### 5. Run the Application

**For Web:**

1. Start the backend server in one terminal:
   ```bash
   cd server
   dart run bin/server.dart
   ```

2. Start Flutter web in another terminal:
   ```bash
   flutter run -d chrome
   # Or use web-server
   flutter run -d web-server --web-port 8080
   ```

**For Android (Debug):**
```bash
flutter run -d android
# Or with token
flutter run --dart-define=CLASH_ROYALE_API_TOKEN=your_token -d android
```

**Build Android APK:**
```bash
flutter build apk --dart-define=CLASH_ROYALE_API_TOKEN=your_token
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

**Build for Web:**
```bash
flutter build web --dart-define=CLASH_ROYALE_API_TOKEN=your_token
# Output will be in: build/web/
```

### Serving Web Build on Port 8080

To serve the built web application locally on port 8080:

1. Build the web app:
   ```bash
   flutter build web --release --dart-define=CLASH_ROYALE_API_TOKEN=your_token
   ```

2. Serve using Python (simplest method):
   ```bash
   cd build/web
   python3 -m http.server 8080
   ```
   Then visit [http://localhost:8080](http://localhost:8080)

> [!TIP]
> For development, you can also run: `flutter run -d web-server --web-port 8080`

## 📖 Usage

1. Launch the app
2. Enter your Clash Royale player tag (e.g., `#2PP` or just `2PP`)
3. Tap "Search"
4. View your stats and get roasted! 🔥

### Finding Your Player Tag

1. Open Clash Royale on your device
2. Tap your profile icon
3. Your player tag is displayed under your name (starts with #)

## 🎯 What Gets Analyzed

- **Win Rate**: Overall and recent performance
- **Trophy Count**: Current trophies vs. personal best
- **Card Levels**: Average card level in your collection
- **Battle History**: Recent wins and losses
- **Current Deck**: Your active deck composition
- **Three Crown Wins**: Total domination count

## 🤣 Roast Categories

The app generates roasts based on:

- Low win rate (<50%)
- Trophy count relative to king level
- Card levels below average
- Recent losing streaks
- Poor recent performance

Don't worry - if you're doing well, you'll get compliments instead! 😊

## 🛠️ Technical Stack

- **Framework**: Flutter 3.38.3
- **Language**: Dart 3.10.1
- **State Management**: Provider
- **HTTP Client**: http package
- **Image Caching**: cached_network_image
- **Fonts**: Google Fonts (Poppins)
- **API**: Official Clash Royale API

## 🎨 Design Features

- Clash Royale themed color palette
- Smooth animations and transitions
- Gradient backgrounds
- Responsive layouts
- Interactive hover/tap effects
- Progress bars and custom widgets
- Loading and error states

## ⚠️ Troubleshooting

### "Error: 403 - Forbidden"
- Your API token is invalid or expired
- Your IP address has changed (regenerate the key with your current IP)

### "Error: 404 - Not Found"
- The player tag is incorrect
- Make sure you're copying the tag correctly from the game

### "Error: 503 - Service Unavailable"
- The Clash Royale API is temporarily down
- Try again in a few minutes

### Rate Limiting
- The API has rate limits
- If you get rate limit errors, wait a few minutes before trying again

## 📝 Project Structure

```
project_v2/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/
│   │   └── app_config.dart          # API configuration
│   ├── models/
│   │   ├── player_data.dart         # Player data model
│   │   ├── stats.dart               # Stats model
│   │   ├── roast.dart               # Roast model
│   │   └── card.dart                # Card model
│   ├── services/
│   │   ├── api_service.dart         # Clash Royale API service
│   │   ├── roast_generator.dart     # Roast generation logic
│   │   └── stats_analyzer.dart      # Stats analysis
│   ├── utils/
│   │   └── card_level_converter.dart # Card level utilities
│   ├── providers/
│   │   └── player_provider.dart     # State management
│   ├── screens/
│   │   ├── home_screen.dart         # Homepage with search
│   │   └── stats_screen.dart        # Player stats display
│   └── widgets/
│       ├── animated_background.dart
│       ├── player_header.dart
│       ├── stat_card.dart
│       ├── roast_card.dart
│       ├── deck_card.dart
│       └── feature_card.dart
├── assets/
│   ├── emotes/                      # Emote images
│   └── .env                         # Environment variables
└── pubspec.yaml                     # Dependencies
```

## 🎮 Example Player Tags

Try these popular players:
- `#2PP`
- `#Y9UVY82C`

## 🔒 Privacy & Security

- This app only reads public player data
- No data is stored or logged
- API tokens are configured via dart-define or in local config

## 📱 Platform Support

- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Android (API 21+)
- ❌ iOS (requires Apple developer account)
- ❌ Desktop (Windows/Mac/Linux - can be added if needed)

## 🤝 Contributing

This is a conversion of the original Flask Python project. Feel free to:
- Add more roast variations
- Include clan statistics
- Compare multiple players
- Add achievement tracking
- Create custom roast themes

## 📄 License

Free to use and modify for personal projects!

---

**Enjoy getting roasted! 🔥⚔️**

Converted from Flask (Python) to Flutter by Google's Antigravity AI.
