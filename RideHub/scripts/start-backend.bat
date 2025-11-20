@echo off
echo ========================================
echo Starting RideHub Backend Server
echo ========================================
echo.

cd server

if not exist ".env" (
    echo ERROR: .env file not found!
    echo Please copy .env.example to .env and configure it.
    echo.
    pause
    exit /b 1
)

if not exist "node_modules" (
    echo Installing dependencies...
    call npm install
    echo.
)

echo Starting server...
echo.
call npm start

pause
