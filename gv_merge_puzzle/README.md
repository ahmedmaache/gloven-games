# Merge Metrics (2048-Style Puzzle)

A number merge puzzle game for Global Ventures founders.

## 🎮 Gameplay
- Swipe in any direction to move all tiles
- When two tiles with the same number collide, they merge and double
- Goal: Create the 2048 tile!
- Game over when no moves are possible

## 🎨 Customization

Edit `lib/config.dart`:
- `startupName` - Your startup name
- `appTitle` - Game title (e.g., "Merge Metrics", "Number Crunch")
- `primaryColor` - Theme color
- `tileColors` - Color mapping for each tile value

## 📦 Building for Release

```bash
# Build Android App Bundle
flutter build appbundle

# The AAB will be at:
# build/app/outputs/bundle/release/app-release.aab
```

## 🛡️ Google Play Checklist

### Package Name
Change `com.gloven.startup.gv_merge_puzzle` to your own unique ID:
1. Edit `android/app/build.gradle` → `applicationId`
2. Update `AndroidManifest.xml` if needed

### App Icon
Replace files in `android/app/src/main/res/mipmap-*/`

### Data Safety Form
- Does app collect data? **NO**
- Does app share data? **NO**
- Is data encrypted? **N/A**

### Content Rating
- Violence: None
- Sexuality: None
- Gambling: None (no real money, no simulated gambling)
- User interaction: None (fully offline)

## ⚖️ Legal
Template provided as-is. Founders must review Google Play policies before publishing.
