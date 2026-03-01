#!/bin/bash

echo "🚀 Welcome to the Dhaher Trading Plan AI Setup Script!"
echo "This script will guide you through the installation process."
echo "--------------------------------------------------------"

# --- Check for Dependencies ---
echo "Checking for dependencies..."

# Check for Flutter, Node.js, and Python/Pip
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter could not be found. Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi
if ! command -v node &> /dev/null; then
    echo "❌ Node.js could not be found. Please install Node.js: https://nodejs.org/"
    exit 1
fi
if ! command -v pip &> /dev/null; then
    echo "❌ pip could not be found. Please ensure Python and pip are installed."
    exit 1
fi

echo "✅ All dependencies found."
echo "--------------------------------------------------------"

# --- Install Packages ---
echo "📦 Installing required packages..."

echo "Installing Flutter packages..."
(cd flutter_app && flutter pub get)

echo "Installing WhatsApp Bot packages..."
(cd whatsapp_bot && npm install)

echo "Installing Python client packages..."
pip install -r python_client/requirements.txt

echo "✅ Packages installed successfully."
echo "--------------------------------------------------------"

# --- API Key Configuration ---
echo "🔑 Now, let's configure your API keys and URLs."
echo "You can find these in your service provider dashboards."

read -p "Enter your Google Apps Script Web App URL: " APPS_SCRIPT_URL
read -p "Enter your LLM7 API Key: " LLM7_API_KEY
read -p "Enter your NewsAPI.org Key: " NEWS_API_KEY
read -p "Enter your Finnhub.io Key: " FINNHUB_API_KEY
read -p "Enter your WhatsApp Bot Server URL (e.g., http://localhost:3000/send): " WA_BOT_URL

# --- Update Files ---
echo "⚙️ Configuring the application..."

# Update Flutter api_service.dart
sed -i.bak "s|https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec|$APPS_SCRIPT_URL|g" "flutter_app/lib/services/api_service.dart"

# Create .env file for Google Apps Script
echo "Creating Google Apps Script properties file..."
cat > google_apps_scripts/properties.env << EOL
LLM7_API_KEY=$LLM7_API_KEY
NEWS_API_KEY=$NEWS_API_KEY
FINNHUB_API_KEY=$FINNHUB_API_KEY
WHATSAPP_API_URL=$WA_BOT_URL
EOL

echo "✅ Configuration complete!"
echo "--------------------------------------------------------"
echo "🎉 Setup is finished! You can now run the application using the launch.sh script."
echo "Before you do, make sure to deploy your Google Apps Script with the new properties."
