# Session 04 — Polish, Theme, and APK Build

## Goal
Apply consistent visual theme, add small UX improvements, configure Android
metadata, build a signed release APK, and verify it installs cleanly on device.

---

## Step 1 — App Theme

Replace the `ThemeData` in `main.dart` with a complete, consistent theme.
The palette is calm and academic — not toy-like, but approachable.

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF3A7CA5), // muted blue
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  fontFamily: 'Roboto',
  cardTheme: CardTheme(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 1,
  ),
),
```

---

## Step 2 — Android App Metadata

### android/app/src/main/AndroidManifest.xml

Set the app label and remove the debug banner. Verify the `<application>` tag has:

```xml
android:label="PrepWise"
android:icon="@mipmap/ic_launcher"
```

### android/app/build.gradle

Verify these values:
```gradle
defaultConfig {
    applicationId "com.prepwise.app"
    minSdkVersion 21
    targetSdkVersion 34
    versionCode 1
    versionName "1.0.0"
}
```

---

## Step 3 — App Icon

If an icon PNG is not available, generate a simple placeholder using Flutter's
launcher icon package, or use the default Flutter icon for now. Add this note
to CLAUDE.md for later:

```
TODO: Replace android/app/src/main/res/mipmap-*/ic_launcher.png
      with a custom PrepWise icon (a stylized "P" or preposition symbol).
      Use flutter_launcher_icons package when icon is ready.
```

---

## Step 4 — UX Improvements

### 4a — Back navigation guard on CardScreen

In `CardScreen`, add a `PopScope` wrapper to prevent accidental back-swipe
mid-session. If user presses back, show a confirmation dialog.

Wrap the `Scaffold` in `CardScreen` with:

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave session?'),
        content: const Text('Your progress in this session will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave')),
        ],
      ),
    );
    if (shouldLeave == true && context.mounted) {
      Navigator.pop(context);
    }
  },
  child: Scaffold( ... ),
),
```

### 4b — Haptic feedback on answer

In `_handleAnswer` in `CardScreen`, add haptic feedback:

```dart
import 'package:flutter/services.dart';

// On correct:
HapticFeedback.lightImpact();

// On wrong:
HapticFeedback.mediumImpact();
```

### 4c — Mastery celebration on CardScreen

When the user answers a card and it becomes mastered (streak just hit 3),
briefly show a congratulation badge before the regular feedback overlay.
In `_handleAnswer`, after calling `progress.recordCorrect(cardId)`:

```dart
final cardProgress = progress.progressFor(card.id);
if (cardProgress.mastered && cardProgress.streak == 3) {
  // Show brief snackbar — the overlay will appear immediately after
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('⭐  Card mastered!'),
      duration: Duration(milliseconds: 1200),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
```

### 4d — Irregular badge on CardScreen

If the current card has `isIrregular == true`, show a small badge above the
sentence:

```dart
if (card.isIrregular)
  Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: theme.colorScheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '⚠️  Fixed phrase — no rule applies',
      style: TextStyle(
        fontSize: 12,
        color: theme.colorScheme.onTertiaryContainer,
      ),
    ),
  ),
```

### 4e — Famous badge on CardScreen

If `card.isFamous == true`, show a similar badge:

```dart
if (card.isFamous)
  Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: theme.colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '🎬  Famous line',
      style: TextStyle(
        fontSize: 12,
        color: theme.colorScheme.onSecondaryContainer,
      ),
    ),
  ),
```

---

## Step 5 — Signing the Release APK

The user already has a keystore from another project. Create a new keystore
for PrepWise or reuse the existing one. If creating a new one:

```bash
keytool -genkey -v \
  -keystore ~/keys/prepwise.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias prepwise \
  -dname "CN=PrepWise, OU=, O=, L=, S=, C=DK"
```

### android/key.properties

Create this file (NOT in version control — add to .gitignore):

```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=prepwise
storeFile=/home/USERNAME/keys/prepwise.jks
```

### android/app/build.gradle

Add signing config before `buildTypes`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### .gitignore

Add to project root `.gitignore`:
```
android/key.properties
*.jks
*.keystore
```

---

## Step 6 — Build the APK

```bash
flutter build apk --release
```

The signed APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Step 7 — Install and Verify on Device

```bash
flutter install --release
```

Or copy the APK manually:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Verification checklist:
- [ ] App installs cleanly (no "parse error")
- [ ] App icon appears in launcher
- [ ] App name shows as "PrepWise"
- [ ] HomeScreen loads with all 7 clusters
- [ ] Full session completes without crash
- [ ] Progress persists after closing and reopening app
- [ ] Mix It Up works
- [ ] Famous Lines works
- [ ] Reset All Progress works
- [ ] Back guard on CardScreen triggers dialog

---

## Step 8 — Distribution

Send the APK file. Recipients need to:
1. Enable **Install from unknown sources** (Settings → Apps → Special app access → Install unknown apps → allow their file manager or browser)
2. Open the APK file and tap Install

This is a one-time step per device. Subsequent updates can be installed the
same way — the new APK will replace the old one if the signing key matches.

---

## Optional Next Features (Post-Launch)

Add these as future CLI sessions if needed:

- **Difficulty filter** — let user choose to see only difficulty_1/2/3 cards in a cluster.
- **Streak screen** — show a visual streak counter or calendar of daily practice.
- **Bookmark cards** — allow user to flag cards to review again.
- **Tip of the day** — show a random rule from the rules bank on the HomeScreen.
- **Dark mode** — add `darkTheme` to `MaterialApp`.
- **Custom cards** — in-app form to add a new card (writes to local storage, not JSON).
- **Export progress** — share a summary as text for a teacher to see.

---

## Final Notes on Adding Cards

When you want to add sentences from external sources:
1. Open `assets/data/prepositions.json`
2. Find the appropriate cluster by its `id`
3. Append a new object to its `cards` array using the template in CLAUDE.md
4. Use the next available custom ID (`card_custom_001`, `card_custom_002`, etc.)
5. Run `flutter run` — the new card appears immediately, no rebuild needed

No code changes required. The JSON is hot-reloaded on debug builds.
On release builds, rebuild the APK and redistribute.
