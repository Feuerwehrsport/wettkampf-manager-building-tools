@ECHO OFF

PUSHD %~dp0.
SET ROOT_DIR=%CD%
POPD

SET PATH=%ROOT_DIR%\Ruby2.1.0\bin;%ROOT_DIR%\Ruby2.1.0\lib\ruby\gems\2.1.0\bin;%ROOT_DIR%\DevKit\bin;%PATH%

ruby wettkampf-manager-building-tools-master/install.rb first
