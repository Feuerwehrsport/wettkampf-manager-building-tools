@ECHO OFF

PUSHD %~dp0.
SET ROOT_DIR=%CD%
POPD

SETLOCAL EnableExtensions EnableDelayedExpansion

>"%temp%\wettkampfmanagerpath.txt" echo(!ROOT_DIR!
findstr /r ".*[()<>\"\"%%].*" "%temp%\wettkampfmanagerpath.txt" >nul
if %errorlevel% equ 0 (
  goto :patherror
)
findstr /r /c:"[ ]" "%temp%\wettkampfmanagerpath.txt" >nul
if %errorlevel% equ 0 (
  goto :patherror
)
ENDLOCAL

SET PATH=%ROOT_DIR%\ruby\bin;%ROOT_DIR%\ruby\lib\ruby\gems\2.6.0\bin;%PATH%
SET RAILS_ENV=production

PUSHD %ROOT_DIR%\wettkampf-manager
bundle exec rails server -e production -b 0.0.0.0 -p 80
POPD

PAUSE
goto :eof

:patherror

echo.
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo.
echo    Der Pfad darf keine Leerzeichen oder andere Sonderzeichen enthalten.
echo           Aktueller Pfad:
echo           %ROOT_DIR%
echo.
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo.
PAUSE

goto :eof
