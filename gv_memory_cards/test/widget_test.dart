// Basic Flutter widget test for Memory Cards game.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:gv_memory_cards/main.dart';
import 'package:gv_memory_cards/providers/theme_provider.dart';
import 'package:gv_memory_cards/providers/game_settings_provider.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app with providers and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => GameSettingsProvider()),
        ],
        child: const GVMemoryCardsApp(),
      ),
    );

    // Wait for splash screen animations
    await tester.pump(const Duration(milliseconds: 500));

    // Verify app loaded (splash screen should be visible)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
