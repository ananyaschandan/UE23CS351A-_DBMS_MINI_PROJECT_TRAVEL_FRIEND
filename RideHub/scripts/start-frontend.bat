@echo off
echo ========================================
echo Starting RideHub Frontend
echo ========================================
echo.

if not exist ".env" (
    echo WARNING: .env file not found!
    echo Creating from .env.example...
    copy .env.example .env
    echo Please edit .env file and add your API keys.
    echo.
)

if not exist "node_modules" (
    echo Installing dependencies...
    call npm install
    echo.
)

echo Starting development server...
echo Frontend will be available at: http://localhost:5173
echo.
call npm run dev

pause
