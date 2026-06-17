@echo off
rem Install or update Voice Manager's slash commands.
rem Double-click this file, then pick an option from the menu.
cd /d "%~dp0"
"%~dp0..\luvit.exe" initSlash.lua
pause
