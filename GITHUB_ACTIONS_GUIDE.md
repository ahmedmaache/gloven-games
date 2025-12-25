# 🚀 GitHub Actions Build Setup Guide

## Quick Start

Your GitHub Actions workflows are now configured to build all 11 Gloven Games apps!

## Required GitHub Secrets

Before running the workflows, you must configure these secrets in your GitHub repository:

**Navigate to:** `https://github.com/YOUR_USERNAME/Gloven-Games/settings/secrets/actions`

### 1. `KEYSTORE_BASE64`
The base64-encoded keystore file.

**Your keystore is already encoded in:** `use_github_ressources/keystore_base64.txt`

```
Copy the entire contents of keystore_base64.txt and paste it as the secret value.
```

### 2. `KEYSTORE_PASSWORD`
```
changeit
```
⚠️ **Important:** Replace with your actual keystore password!

### 3. `KEY_PASSWORD`
```
changeit
```
⚠️ **Important:** Replace with your actual key password!

### 4. `KEY_ALIAS`
```
gloven-key
```

---

## Available Workflows

### 1. Build All Apps (`build-all-apps.yml`)
- **Trigger:** Push to main/master OR manual dispatch
- **Builds:** All 11 apps in parallel (5 concurrent)
- **Output:** Signed AAB + APK files as artifacts
- **Optional:** Creates a GitHub Release with all builds

**To run manually:**
1. Go to **Actions** tab in GitHub
2. Select **"Build All Gloven Games"**
3. Click **"Run workflow"**

### 2. Build Single App (`build-single-app.yml`)
- **Trigger:** Manual dispatch only
- **Options:**
  - Select which app to build
  - Toggle APK build
  - Toggle GitHub Release creation

**To run:**
1. Go to **Actions** tab
2. Select **"Build Single App"**
3. Click **"Run workflow"**
4. Choose your options
5. Click **"Run workflow"**

---

## Apps Included (11 Total)

| App ID | Game Name |
|--------|-----------|
| gv_catch_fall | Catch & Fall |
| gv_funny_sounds | Funny Sounds |
| gv_match3 | Match 3 |
| gv_memory_cards | Memory Cards |
| gv_merge_puzzle | Merge Puzzle |
| gv_reflex_tap | Reflex Tap |
| gv_runner | Gloven Runner |
| gv_stack_blocks | Stack Blocks |
| gv_startup_quiz | Startup Quiz |
| gv_swipe_avoider | Swipe Avoider |
| gv_tictactoe | Tic Tac Toe |

---

## Downloading Build Artifacts

After a successful build:

1. Go to the **Actions** tab
2. Click on the completed workflow run
3. Scroll down to **Artifacts**
4. Download the AAB/APK files

**Artifact naming:** `{app_name}-aab-v{version}` and `{app_name}-apk-v{version}`

**Retention:** 30 days

---

## Troubleshooting

### ❌ "Keystore not found"
- Verify `KEYSTORE_BASE64` secret is set correctly
- Make sure you copied the ENTIRE contents of `keystore_base64.txt`

### ❌ "Signing failed"
- Check that `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, and `KEY_ALIAS` match your keystore

### ❌ "Flutter pub get failed"
- Check for dependency issues in the specific app's `pubspec.yaml`

### ❌ "Build timeout"
- GitHub Actions has a 6-hour timeout
- Individual app builds typically take 3-5 minutes

---

## Cost & Limits

- **Free tier:** 2,000 minutes/month
- **Per build:** ~3-5 minutes per app
- **Full build (11 apps):** ~15-25 minutes total (parallel)
- **Artifact storage:** Up to 500MB (free tier)

---

## Next Steps

1. ✅ Configure GitHub Secrets
2. ✅ Push code to GitHub
3. ✅ Trigger workflow (manual or push)
4. ✅ Download AAB files
5. ✅ Upload to Google Play Console

---

## Commands for Local Testing

```powershell
# Build a single app locally
cd gv_catch_fall
flutter build appbundle --release

# Build all apps locally (PowerShell)
Get-ChildItem -Directory -Filter "gv_*" | ForEach-Object {
    Write-Host "Building $($_.Name)..."
    Set-Location $_.FullName
    flutter build appbundle --release
    Set-Location ..
}
```

---

*Last Updated: 2025-12-25*
