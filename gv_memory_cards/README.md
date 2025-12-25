# Startup Memory Cards Game

A simple, policy-safe memory matching game for Global Ventures founders.

## 🎮 Gameplay
- 4x4 grid (16 cards = 8 pairs)
- Tap to flip cards
- Match pairs of startup-themed icons
- Track moves and time

## 🎨 Customization

Edit `lib/config.dart`:
- `startupName` - Your startup's name
- `appTitle` - Game title
- `accentColor` - Primary brand color
- `cardIcons` - Icons used on cards

### Changing Card Icons
Replace icons in `cardIcons` list with any Flutter `Icons.*` value. Keep exactly 8 icons for 16 cards (8 pairs).

### Changing Package Name
1. Open `android/app/build.gradle`
2. Change `applicationId`
3. Update `android/app/src/main/AndroidManifest.xml` if needed

## 🛡️ Google Play Policy Checklist

- [x] **No permissions** - App is fully offline
- [x] **No data collection** - Nothing tracked or stored
- [x] **No ads** - Clean experience
- [x] **Family-friendly** - Neutral, educational icons
- [ ] **Privacy Policy** - Add one if you later add network features

## 📦 Build for Release
```bash
flutter build appbundle
```
Upload `build/app/outputs/bundle/release/app-release.aab` to Google Play Console.

## ⚖️ Legal
This template is designed for policy safety. Founders must review Google Play policies before publishing.
