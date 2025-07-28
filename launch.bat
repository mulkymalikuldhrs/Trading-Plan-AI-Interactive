@echo off
echo.
echo ========================================================
echo  Launching Dhaher Trading Plan AI
echo ========================================================
echo.

echo Starting WhatsApp Bot server in a new window...
start "WhatsApp Bot" cmd /c "cd whatsapp_bot && npm start"

echo.
echo Starting Flutter Web App...
cd flutter_app
call flutter run -d chrome

echo.
echo ========================================================
echo  Application is running. Close the terminal windows
echo  to stop the servers.
echo ========================================================
echo.
