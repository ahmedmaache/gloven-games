# Stack Blocks

A block stacking game for Global Ventures founders.

## 🎮 Gameplay
- Block moves horizontally at the top
- Tap to drop it onto the stack
- Misaligned portions get trimmed
- Stack as many blocks as you can!

## 🎨 Customization

Edit `lib/config.dart`:
- `startupName` - Your startup name
- `appTitle` - Game title
- `primaryColor` - Theme color
- `blockColor` - Starting block color
- `blockSpeed` - Horizontal movement speed (increase for harder game)
- `dropSpeed` - How fast blocks fall

## 📱 Difficulty Tweaks

In `lib/config.dart`:
```dart
const double blockSpeed = 4.0;  // Increase for harder game (try 6.0 or 8.0)
const double blockWidth = 100.0; // Decrease for harder game (try 80.0)
```

## 📦 Building for Release
```bash
flutter build appbundle
```

## 🛡️ Google Play Checklist

- [x] Offline only - no network requests
- [x] No data collection
- [x] No ads or in-app purchases
- [x] Abstract blocks - no realistic destruction
- [x] Family-friendly content
- [ ] Check Pre-Launch Report in Play Console
- [ ] Complete Content Rating questionnaire
- [ ] Fill Data Safety form (select "No data collected")

## ⚖️ Legal
Template provided as-is. Review Google Play policies before publishing.
