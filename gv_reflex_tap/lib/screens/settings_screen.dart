import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../providers/theme_provider.dart';
import '../providers/game_settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final gameSettings = Provider.of<GameSettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: primaryColor, foregroundColor: Colors.white, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _buildSectionHeader('Game Options', isDark),
        Card(child: Column(children: [
          SwitchListTile(title: const Text('Sound Effects'), subtitle: const Text('Enable game sounds'), value: gameSettings.soundEnabled, onChanged: (value) => gameSettings.setSoundEnabled(value), secondary: Icon(gameSettings.soundEnabled ? Icons.volume_up : Icons.volume_off, color: primaryColor)),
          const Divider(height: 1),
          SwitchListTile(title: const Text('Vibration'), subtitle: const Text('Enable haptic feedback'), value: gameSettings.vibrationEnabled, onChanged: (value) => gameSettings.setVibrationEnabled(value), secondary: Icon(gameSettings.vibrationEnabled ? Icons.vibration : Icons.phone_android, color: primaryColor)),
        ])),
        const SizedBox(height: 24),
        _buildSectionHeader('Display Options', isDark),
        Card(child: ListTile(leading: Icon(Icons.brightness_6, color: primaryColor), title: const Text('Theme'), subtitle: Text(_getThemeModeText(themeProvider.themeMode)), trailing: const Icon(Icons.chevron_right), onTap: () => _showThemeDialog(context, themeProvider))),
        const SizedBox(height: 24),
        _buildSectionHeader('About & Credits', isDark),
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(gradient: const LinearGradient(colors: gradientColors), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.touch_app, size: 40, color: Colors.white)),
          const SizedBox(height: 16),
          const Text(appName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('Version 1.0.2', style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : Colors.grey[600])),
          const SizedBox(height: 16), const Divider(), const SizedBox(height: 16),
          const Text('by \$developerName', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Powered by Global Ventures – gloven.org', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey[600]), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.withAlpha(26), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.withAlpha(77))), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle, color: Colors.green, size: 16), SizedBox(width: 6), Text('Offline & Ad-free', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500))])),
          const SizedBox(height: 16),
          Text('Built with Flutter', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500])),
        ]))),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : Colors.grey[600], letterSpacing: 0.5)));

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) { case ThemeMode.system: return 'System default'; case ThemeMode.light: return 'Light'; case ThemeMode.dark: return 'Dark'; }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Choose Theme'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      RadioListTile<ThemeMode>(title: const Text('System default'), value: ThemeMode.system, groupValue: themeProvider.themeMode, onChanged: (v) { Navigator.pop(context); themeProvider.setThemeMode(v!); }),
      RadioListTile<ThemeMode>(title: const Text('Light'), value: ThemeMode.light, groupValue: themeProvider.themeMode, onChanged: (v) { Navigator.pop(context); themeProvider.setThemeMode(v!); }),
      RadioListTile<ThemeMode>(title: const Text('Dark'), value: ThemeMode.dark, groupValue: themeProvider.themeMode, onChanged: (v) { Navigator.pop(context); themeProvider.setThemeMode(v!); }),
    ])));
  }
}
