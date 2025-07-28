@echo off
echo.
echo ========================================================
echo  Welcome to the Dhaher Trading Plan AI Setup Script
echo ========================================================
echo.

echo Checking for dependencies...

where /q flutter
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed. Please install it from https://flutter.dev
    exit /b
)

where /q node
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed. Please install it from https://nodejs.org
    exit /b
)

echo Dependencies found.
echo.

echo ========================================================
echo Installing packages...
echo ========================================================
echo.

echo Installing Flutter packages...
cd flutter_app
call flutter pub get
cd ..

echo Installing WhatsApp Bot packages...
cd whatsapp_bot
call npm install
cd ..

echo.
echo ========================================================
echo API Key Configuration
echo ========================================================
echo.

set /p APPS_SCRIPT_URL="Enter your Google Apps Script URL: "
set /p LLM7_API_KEY="Enter your LLM7 API Key: "
set /p NEWS_API_KEY="Enter your NewsAPI.org Key: "
set /p FINNHUB_API_KEY="Enter your Finnhub.io Key: "
set /p WA_BOT_URL="Enter your WhatsApp Bot Server URL: "

echo.
echo ========================================================
echo Configuring files...
echo ========================================================
echo.

powershell -Command "(gc flutter_app/lib/services/api_service.dart) -replace 'https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec', '%APPS_SCRIPT_URL%' | Out-File -encoding ASCII flutter_app/lib/services/api_service.dart"

(
echo LLM7_API_KEY=%LLM7_API_KEY%
echo NEWS_API_KEY=%NEWS_API_KEY%
echo FINNHUB_API_KEY=%FINNHUB_API_KEY%
echo WHATSAPP_API_URL=%WA_BOT_URL%
) > google_apps_scripts/properties.env

echo.
echo ========================================================
echo SETUP COMPLETE!
echo You can now run the application using launch.bat
echo ========================================================
echo.
