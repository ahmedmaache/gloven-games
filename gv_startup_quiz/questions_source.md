# Questions Source & Content Guidelines

## About the Questions

The 20 questions included in `lib/data/questions.dart` are **example content** designed to teach basic entrepreneurship concepts.

### Topics Covered:
- MVP (Minimum Viable Product)
- Pitch decks
- Bootstrapping
- Pivoting
- ROI, CAC, and other metrics
- Funding (angels, VCs)
- Business models
- Startup terminology

## Content Guidelines

### ✅ DO:
- Keep questions educational and informational
- Use generic business concepts
- Provide helpful explanations
- Make questions fun and engaging

### ❌ DON'T:
- Promise financial gains or investment returns
- Give legal or tax advice
- Make medical or health claims
- Include political or controversial content
- Reference specific companies negatively
- Use copyrighted quiz questions from other sources

## Customizing Questions

Founders can modify `lib/data/questions.dart`:

```dart
QuizQuestion(
  question: "Your question here?",
  options: [
    "Option A",
    "Option B", 
    "Option C",
    "Option D"
  ],
  correctIndex: 1, // 0-3, where correct answer is located
  explanation: "Why this is the correct answer.",
),
```

## Localization

To add multiple languages:
1. Create separate question lists per language
2. Use `flutter_localizations` package
3. Load appropriate question list based on locale

## Google Play Compliance

When creating your own questions:

1. **No misleading claims** - Don't promise users will become rich or successful
2. **No professional advice** - Mark clearly as "educational" not professional advice
3. **No harmful content** - Avoid discrimination, hate speech, or dangerous content
4. **Age-appropriate** - Keep content suitable for general audiences

## Disclaimer

Include in your app description:
> "This quiz is for educational purposes only. It does not constitute professional business, legal, or financial advice."
