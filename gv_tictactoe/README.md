# Tic Tac Toe

Classic Tic-Tac-Toe vs AI for Global Ventures founders.

## 🎮 Gameplay
- Player is X, AI is O
- Tap to place your mark
- Get 3 in a row to win!
- Session stats tracked (wins/losses/draws)

## 🤖 AI Behavior
The AI uses a simple heuristic:
1. Try to win (if can complete 3 in a row)
2. Block player (if player can win)
3. Take center or corners
4. Random move

This makes it beatable but still challenging.

## 🎨 Customization

Edit `lib/config.dart`:
- `startupName` - Your startup name
- `appTitle` - Game title
- `primaryColor` - Theme color
- `xColor` - Player X color
- `oColor` - AI O color

## 📦 Building for Release
```bash
flutter build appbundle
```

## 🛡️ Policy Safety

See `LEGAL_NOTES.md` for detailed policy checklist.

- ✅ No internet required
- ✅ No data collection
- ✅ No online leaderboard
- ✅ Family-friendly
- ✅ Single-player only

## ⚖️ Legal
Review Google Play policies before publishing. This template minimizes risk but doesn't guarantee approval.
