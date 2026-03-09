# 🚀 Social Sage: Deployment & Building Guide

Follow these steps to run the app on your local system or build an Android APK.

---

## 1. Prerequisites
Ensure you have the following installed on your machine:
- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio**: Required for the Android SDK and building APKs.
- **Java JDK**: Ensure `java -version` works in your terminal.

---

## 2. 🌍 Run on Web (Localhost)
To test the app in your browser:

1. Open your terminal in the project root: `f:\khaki\projects\social posting app locally\social_sage`
2. Run the following command:
   ```bash
   flutter run -d chrome
   ```
3. This will launch the app at `http://localhost:XXXX/`.

> [!NOTE]
> **Web Limitations**: Since this MVP uses `sqflite` for mobile-native performance, the database features might require the [sqflite_common_ffi_web](https://pub.dev/packages/sqflite_common_ffi_web) package or a switch to `drift` for persistent data on Web. For UI testing, the app will run perfectly.

---

## 3. 📱 Build Android APK
To generate a file you can install on your phone:

1. Open your terminal in the project root.
2. Run the build command:
   ```bash
   flutter build apk --release
   ```
3. Once completed, the APK file will be located at:
   `build/app/outputs/flutter-apk/app-release.apk`

> [!TIP]
> To build for specific architectures (making the file size smaller), use:
> `flutter build apk --split-per-abi`

---

## 4. 🛠 Common Troubleshooting
- **Missing Dependencies**: Run `flutter pub get` first.
- **Android SDK errors**: Run `flutter doctor` to check for missing setup steps.
- **Gradle errors**: Ensure you have an active internet connection for the first build as Gradle needs to download platform files.

---

## 5. Next Steps
Once you have the APK:
- Transfer it to your Android device via USB or Google Drive.
- Open the file on your phone and select "Install" (you may need to allow "Install from unknown sources").
