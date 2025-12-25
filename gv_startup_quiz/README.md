# Startup Quiz

An offline entrepreneurship quiz game for Global Ventures founders.

## 🎮 Gameplay
- 20 multiple-choice questions about startups
- Learn about MVPs, funding, metrics, and more
- Get instant feedback with explanations
- See your final score with personalized feedback

## 🎨 Customization

### Branding
Edit `lib/config.dart`:
- `startupName` - Your startup name
- `appTitle` - Quiz title
- `primaryColor` - Theme color

### Questions
Edit `lib/data/questions.dart` to:
- Add your own questions
- Modify existing ones
- Change explanations

See `questions_source.md` for content guidelines.

## 📦 Building for Release

```bash
# Get dependencies (if needed)
flutter pub get

# Build release AAB
flutter build appbundle
```

Upload `build/app/outputs/bundle/release/app-release.aab` to Google Play Console.

## 🛡️ Google Play Safety

- ✅ Completely offline - no network requests
- ✅ No data collection or analytics
- ✅ No dangerous permissions
- ✅ Educational content only
- ✅ No misleading health/finance claims
- ✅ Family-friendly

### Important Notes:
- Questions are educational, NOT professional advice
- Add disclaimer in Play Store description
- Review content before publishing

## ⚖️ Legal

See `questions_source.md` for content compliance guidelines.
This template is provided by Global Ventures (gloven.org).
Founders are responsible for final content and compliance.
