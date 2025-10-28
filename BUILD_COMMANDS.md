# 🛠️ Build & Test Commands

## Quick Reference for The Winter Arc App

---

## 📦 Setup

### Install Dependencies
```bash
flutter pub get
```

### Check Flutter Setup
```bash
flutter doctor
```

---

## 🧪 Development

### Run in Debug Mode
```bash
flutter run
```

### Run on Specific Device
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Hot Reload
While app is running:
- Press `r` - Hot reload
- Press `R` - Hot restart
- Press `q` - Quit

---

## 🔍 Testing & Analysis

### Run Tests
```bash
flutter test
```

### Analyze Code
```bash
flutter analyze
```

### Format Code
```bash
flutter format .
```

### Check for Outdated Packages
```bash
flutter pub outdated
```

---

## 🏗️ Build

### Debug Build (APK)
```bash
flutter build apk --debug
```

### Release Build (APK)
```bash
flutter build apk --release
```

### Release Build (App Bundle for Play Store)
```bash
flutter build appbundle --release
```

### Build and Install Release
```bash
flutter build apk --release
flutter install --release
```

---

## 📱 Installation

### Install on Connected Device
```bash
flutter install
```

### Install Specific APK
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧹 Clean Build

### Clean Build Files
```bash
flutter clean
```

### Full Clean & Rebuild
```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📊 Performance

### Build Size Analysis
```bash
flutter build apk --analyze-size
```

### Profile Mode
```bash
flutter run --profile
```

### Performance Overlay
While app is running:
- Press `P` - Toggle performance overlay

---

## 🐛 Debugging

### View Logs
```bash
flutter logs
```

### ADB Logcat
```bash
adb logcat
```

### Clear App Data
```bash
adb shell pm clear com.winterarc.app
```

---

## 📦 Release Checklist

### Before Building Release:

1. **Update Version**
```yaml
# pubspec.yaml
version: 1.0.0+1
```

2. **Clean Build**
```bash
flutter clean
flutter pub get
```

3. **Run Tests**
```bash
flutter test
flutter analyze
```

4. **Build Release**
```bash
flutter build appbundle --release
```

5. **Test Release**
```bash
flutter build apk --release
flutter install --release
```

---

## 🔐 Signing (Production)

### Generate Key
```bash
keytool -genkey -v -keystore ~/winter-arc-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias winterarc
```

### Create key.properties
```
# android/key.properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=winterarc
storeFile=/path/to/winter-arc-key.jks
```

### Build Signed APK
```bash
flutter build apk --release
```

### Build Signed App Bundle
```bash
flutter build appbundle --release
```

---

## 📍 Build Outputs

### APK Location
```
build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle Location
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 🎯 Common Tasks

### Fresh Start
```bash
flutter clean
flutter pub get
flutter run
```

### Quick Test on Device
```bash
flutter run --release
```

### Build for Distribution
```bash
flutter build appbundle --release
```

### Verify App Size
```bash
flutter build apk --release --analyze-size
```

---

## 🔄 Update Dependencies

### Update All
```bash
flutter pub upgrade
```

### Update Specific Package
```bash
flutter pub upgrade <package-name>
```

---

## 📱 Device Commands

### List Connected Devices
```bash
flutter devices
adb devices
```

### Screen Recording (Testing)
```bash
adb shell screenrecord /sdcard/demo.mp4
# Stop with Ctrl+C
adb pull /sdcard/demo.mp4
```

### Screenshots
```bash
adb shell screencap /sdcard/screenshot.png
adb pull /sdcard/screenshot.png
```

---

## 🚀 Deployment

### Final Build Steps:
```bash
# 1. Clean
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Analyze
flutter analyze

# 4. Build app bundle
flutter build appbundle --release

# 5. Verify output
ls -lh build/app/outputs/bundle/release/
```

### File to Upload to Play Store:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 📝 Notes

- Always test release builds before submission
- Keep keystore file safe (backup!)
- Never commit key.properties to git
- Test on multiple devices if possible
- Check app permissions work correctly
- Verify notifications on Android 13+

---

## ✅ Pre-Submission Checklist

- [ ] Version number updated
- [ ] All tests pass
- [ ] No analyzer warnings
- [ ] Release build successful
- [ ] App tested on device
- [ ] All features working
- [ ] Permissions tested
- [ ] Screenshots captured
- [ ] App bundle signed
- [ ] Ready for upload!

---

*Quick reference for building The Winter Arc app. Stay locked in! 💪❄️*
