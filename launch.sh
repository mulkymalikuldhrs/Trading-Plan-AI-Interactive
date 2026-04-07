#!/bin/bash

echo "🚀 Launching Dhaher Trading Plan AI..."
echo "----------------------------------------"

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "⚠️ .env file not found. Please run setup.sh first."
    exit 1
fi

# Start the WhatsApp Bot in the background
echo "Starting WhatsApp Bot server..."
(cd whatsapp_bot && npm start > bot.log 2>&1 &)

# Start the Flutter Web App with --dart-define
echo "Starting Flutter Web App..."
(cd flutter_app && flutter run -d chrome --dart-define=GAS_URL=$GAS_URL --dart-define=API_KEY=$BOT_API_KEY)

echo "✅ Services are launching."
echo "Press CTRL+C in the Flutter terminal to stop the application."
