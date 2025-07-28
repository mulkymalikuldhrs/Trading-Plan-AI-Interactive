# 🚀 One-Click Setup & Launcher Guide

This guide provides instructions on how to use the automated scripts to install and launch the Dhaher Trading Plan AI.

## 1. Installation (One-Time Setup)

The setup script will check for dependencies, install all necessary packages for Flutter, Node.js, and Python, and prompt you to configure your API keys.

### For macOS & Linux

1.  Open your terminal.
2.  Make the script executable: `chmod +x setup.sh`
3.  Run the script: `./setup.sh`
4.  Follow the on-screen prompts to enter your API keys and URLs.

### For Windows

1.  Double-click the `setup.bat` file.
2.  A command prompt window will open.
3.  Follow the on-screen prompts to enter your API keys and URLs.

The script now handles all package installation automatically.

**Important:** The setup script creates a `properties.env` file in the `google_apps_scripts` directory. You must still **manually copy** these key-value pairs into your Google Apps Script's "Script Properties" section before deploying it.

## 2. Launching the Application

The launch script will start both the Flutter web server and the WhatsApp bot server simultaneously.

### For macOS & Linux

1.  Open your terminal.
2.  Make the script executable: `chmod +x launch.sh`
3.  Run the script: `./launch.sh`

### For Windows

1.  Double-click the `launch.bat` file.

This will open two terminal windows: one for the Flutter app and one for the WhatsApp bot. The Flutter app will automatically open in a new Chrome window.

To stop the application, you can close both terminal windows.
