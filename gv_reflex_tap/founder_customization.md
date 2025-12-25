# Founder Customization Guide

This guide helps non-technical founders customize the Startup Reflex game.

## 🎨 Changing Colors and Text

1. Open the file `lib/config.dart`
2. Edit these values:

```dart
const String startupName = "Your Startup Name";  // Your company name
const String appTitle = "Your Game Title";       // Game title
const Color primaryColor = Color(0xFFFF6B6B);    // Main theme color (hex)
```

### Finding Color Codes
- Use a tool like [colorhexa.com](https://www.colorhexa.com) or Google "color picker"
- Copy the HEX code (e.g., `#FF6B6B`)
- In Flutter, prefix with `0xFF` → `Color(0xFFFF6B6B)`

## 🔷 Changing Target Shape

In `lib/config.dart`:
```dart
const String iconShape = "circle";  // Options: "circle" or "square"
```

## 🖼️ Replacing the Icon with Your Logo

1. Create a PNG logo (recommended size: 512x512)
2. Add to `assets/` folder
3. Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/logo.png
```
4. Replace the Icon widget in `home_screen.dart` and `game_screen.dart` with:
```dart
Image.asset('assets/logo.png', width: 50, height: 50)
```

## 📱 Changing App Name

### Android:
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
android:label="Your App Name"
```

### iOS:
Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>Your App Name</string>
```

## 📦 Changing Package Name (REQUIRED for Google Play)

Your app needs a unique package name to be published.

1. Install the package name changer:
```bash
flutter pub add change_app_package_name --dev
```

2. Run:
```bash
flutter pub run change_app_package_name:main com.yourstartup.reflexgame
```

Or manually edit:
- `android/app/build.gradle` → `applicationId`
- `android/app/src/main/AndroidManifest.xml` → `package`

## 🚀 Building for Release

```bash
flutter build appbundle
```

Upload `build/app/outputs/bundle/release/app-release.aab` to Google Play Console.

## ⚠️ Important Notes

- **No misleading claims**: Don't claim the game provides medical benefits or cognitive training without scientific evidence
- **Content rating**: Answer the questionnaire honestly (this game is suitable for all ages)
- **Data safety**: Select "No data collected" in the Play Console form
