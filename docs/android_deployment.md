# 🤖 Android Deployment Guide

This guide provides instructions on how to build and install the Dhaher Trading Plan AI™ application on an Android device.

## 1. Prerequisites

-   Ensure you have the Flutter SDK installed and configured correctly.
-   You will need an Android device or an emulator set up.

## 2. Building the `.apk` File

To build the Android installer (`.apk`), follow these steps from your terminal, inside the `flutter_app` directory:

1.  **Clean the Project:**
    *   This command removes old build files and artifacts.
    *   `flutter clean`

2.  **Install Dependencies:**
    *   This command ensures all the project's packages are downloaded and up to date.
    *   `flutter pub get`

3.  **Build the Release APK:**
    *   This is the final command that compiles your app into a shareable and installable `.apk` file.
    *   `flutter build apk --release`

## 3. Locating and Installing the APK

-   **File Location:** After the build process is complete, you will find the installer file at the following path:
    *   `flutter_app/build/app/outputs/flutter-apk/app-release.apk`

-   **Installation:**
    1.  Copy this `app-release.apk` file to your Android device.
    2.  Open the file manager on your device, navigate to where you saved the file, and tap on it to install.
    3.  You may need to enable "Install from unknown sources" in your device's security settings to proceed.

Your Dhaher Trading Plan AI application is now installed and ready to use on your Android device.

---

> **Contact:** Mulky Malikul Dhaher — [mulkymalikudhr@mail.com](mailto:mulkymalikudhr@mail.com)
>
> **Disclaimer:** This project is for Education Purpose only. Risiko apapun tidak kita tanggung. (We are not responsible for any risks or damages.)
