@ECHO OFF

PUSHD %~dp0.
SET ROOT_DIR=%CD%
POPD

SET PATH=%ROOT_DIR%\ruby\bin;%ROOT_DIR%\ruby\lib\ruby\gems\2.4.0\bin;%PATH%

ruby %ROOT_DIR%\wrapper\start_console.rb

PAUSE