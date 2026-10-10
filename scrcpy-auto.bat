@echo off
title scrcpy automatico
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scrcpy-auto.ps1"
if errorlevel 1 pause
