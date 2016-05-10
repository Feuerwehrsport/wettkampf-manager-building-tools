@ECHO OFF

PUSHD %~dp0.
SET ROOT_DIR=%CD%
POPD

SET PATH=%ROOT_DIR%\ruby\bin;%ROOT_DIR%\ruby\lib\ruby\gems\2.1.0\bin;%PATH%

ruby %ROOT_DIR%\wrapper\start_server.rb

PAUSE