# Startup Runner Template (Gloven)

2D Endless Runner built for Global Ventures (Algerian Incubator) founders.
Designed for **quick customization**, **no permissions**, and **policy safety**.

## 🚀 How to Run
1. Open this folder in your IDE (VS Code or Android Studio).
2. Run `flutter pub get` to install dependencies.
3. Connect an Android device or emulator.
4. Run `flutter run`.

## 🎨 How to Customize ( Branding )

1. **Open `lib/config.dart`**
   - Change `startupName` to your Startup's name.
   - Change `appTitle` to your Game's title.
   - Change `primaryColor` to your brand color.

2. **Change App Icon** (Optional but recommended)
   - Add `flutter_launcher_icons` to `pubspec.yaml` if you want to automate this, or simply replace `android/app/src/main/res/mipmap-*/ic_launcher.png` manually.

3. **Change Package Name** (CRITICAL for Play Store)
   - Your package name is currently set to `com.gloven.startup.gv_runner`.
   - To publish, you MUST change this to a unique ID like `com.yourstartup.runner`.
   - **Easiest way**: Use `change_app_package_name` package or search/replace in `android/app/build.gradle` and `AndroidManifest.xml`.

## 🛡️ Google Play Policy Checklist

This app is designed to be "Policy Safe" out of the box, but you must confirm:

- [ ] **Data Safety Form**: Answer that you **DO NOT** collect any user data (Contacts, Location, Device ID, etc). This app is offline.
- [ ] **Target Audience**: Select "13+" or "16+" to avoid strict "Designed for Families" requirements unless you specifically want children users.
- [ ] **Ads**: This template has NO ads. Select "My app does not contain ads".

## 📦 Building for Release
1. Run `flutter build appbundle`.
2. Upload the file from `build/app/outputs/bundle/release/app-release.aab` to Google Play Console.
