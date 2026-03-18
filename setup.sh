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

read -p "Enter your Google Apps Script Web App URL: " GAS_URL
read -p "Enter your LLM7 API Key: " LLM7_API_KEY
read -p "Enter your NewsAPI.org Key: " NEWS_API_KEY
read -p "Enter your Finnhub.io Key: " FINNHUB_API_KEY
read -p "Enter your WhatsApp Bot API Key (Secret): " API_KEY
read -p "Enter your User Phone Number (e.g., 628123456789): " USER_PHONE_NUMBER
read -p "Enter your WhatsApp Bot Server URL (e.g., http://localhost:3000/send): " WHATSAPP_API_URL

# --- Create .env file ---
echo "⚙️ Creating central configuration file (.env)..."

cat > .env << EOL
GAS_URL=$GAS_URL
LLM7_API_KEY=$LLM7_API_KEY
NEWS_API_KEY=$NEWS_API_KEY
FINNHUB_API_KEY=$FINNHUB_API_KEY
API_KEY=$API_KEY
USER_PHONE_NUMBER=$USER_PHONE_NUMBER
WHATSAPP_API_URL=$WHATSAPP_API_URL
EOL

# Also sync to whatsapp_bot/.env
cp .env whatsapp_bot/.env

echo "✅ Configuration complete!"
echo "--------------------------------------------------------"
echo "🎉 Setup is finished! You can now run the application using the launch.sh script."
echo "Before you do, make sure to deploy your Google Apps Script and set these properties in Script Properties."
