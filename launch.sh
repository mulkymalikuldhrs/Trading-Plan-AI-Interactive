#!/bin/bash

echo "🚀 Launching Dhaher Trading Plan AI..."
echo "----------------------------------------"

# Start the WhatsApp Bot in the background
echo "Starting WhatsApp Bot server..."
(cd whatsapp_bot && npm start &)
# A simple `npm start` would be `node main.js`. You should add a "start" script to your package.json

# Start the Flutter Web App
echo "Starting Flutter Web App..."
(cd flutter_app && flutter run -d chrome)

echo "✅ Both services are now running."
echo "Press CTRL+C in the Flutter terminal to stop the application."
# You may need to manually kill the node process for the bot.
# A more advanced script would handle this.
