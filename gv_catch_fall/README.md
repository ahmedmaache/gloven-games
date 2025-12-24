# Catch Fall

A casual falling objects catcher game for Global Ventures founders.

## 🎮 Gameplay
- Objects (stars) fall from the top
- Drag the basket left/right to catch them
- Miss 5 objects and it's game over
- Speed increases over time!

## 🎨 Customization

Edit `lib/config.dart`:
- `startupName` - Your startup name
- `appTitle` - Game title
- `primaryColor` - Theme color
- `basketColor` - Basket appearance
- `objectColor` - Falling object color
- `maxMisses` - Lives before game over (default: 5)
- `fallSpeed` - Initial fall speed

## 📱 Localization Ready

Strings are structured for easy localization:
1. Create a `lib/l10n/` folder
2. Extract strings from widgets
3. Use `flutter_localizations` package

## 📦 Building for Release
```bash
flutter build appbundle
```

## 🛡️ Google Play Safety

- ✅ No gambling - just catching objects
- ✅ No real money rewards
- ✅ No user data collection
- ✅ No network requests
- ✅ General casual audience

### Privacy Policy
If you later add analytics or network features, you MUST:
1. Add a privacy policy URL to your Play Store listing
2. Update the Data Safety form accordingly

## ⚖️ Legal
Template provided as-is. Review Google Play policies before publishing.
