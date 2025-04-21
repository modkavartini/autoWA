@echo off
:: Check for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Set execution policy to unrestricted
powershell -Command "Set-ExecutionPolicy Unrestricted -Force"

:: Open a new PowerShell window and run the script
start powershell -NoExit -ExecutionPolicy Unrestricted -File "%~dp0autoWA.ps1"
