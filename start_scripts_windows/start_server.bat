@ECHO OFF

PUSHD %~dp0.
SET ROOT_DIR=%CD%
POPD

SET PATH=%ROOT_DIR%\Ruby2.1.0\bin;%ROOT_DIR%\Ruby2.1.0\lib\ruby\gems\2.1.0\bin;%ROOT_DIR%\DevKit\bin;%ROOT_DIR%\DevKit\mingw\bin;%PATH%

ruby wettkampf-manager-building-tools-master/start_server.rb first

PAUSE