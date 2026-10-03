@echo off
setlocal
chcp 65001 >nul
title Webhook Manager - Build EXE
cd /d "%~dp0"

echo ==============================================
echo   Webhook Manager - Compilation du .exe
echo ==============================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo [ERREUR] Node.js n'est pas installe.
  echo Telecharge-le ici : https://nodejs.org ^(version 20 ou plus^)
  pause
  exit /b 1
)

echo [0/3] Nettoyage et reglages reseau...
if exist node_modules rmdir /s /q node_modules >nul 2>nul
call npm config set fetch-retries 8 >nul
call npm config set fetch-retry-mintimeout 5000 >nul
call npm config set fetch-retry-maxtimeout 120000 >nul
call npm config set fetch-timeout 300000 >nul

echo.
echo [1/3] Installation des dependances ^(3 essais max^)...
set TRIES=0
:install
set /a TRIES+=1
call npm install --no-audit --no-fund --prefer-online
if not errorlevel 1 goto :build
if %TRIES% GEQ 3 goto :error
echo.
echo Echec ^(essai %TRIES%/3^), nouvel essai dans 5 secondes...
timeout /t 5 /nobreak >nul
goto :install

:build
echo.
echo [2/3] Build du site + creation du .exe ^(ca peut prendre quelques minutes^)...
call npm run electron:build
if errorlevel 1 goto :error

echo.
echo [3/3] Termine !
echo Ton fichier est ici : %~dp0dist\Webhook-Manager.exe
if exist "dist\Webhook-Manager.exe" explorer "dist"
pause
exit /b 0

:error
echo.
echo [ERREUR] La compilation a echoue. Regarde les messages ci-dessus.
echo Conseils : mets le dossier dans un chemin court ^(ex: C:\webhook-manager^),
echo desactive temporairement l'antivirus/VPN, puis relance.
pause
exit /b 1
