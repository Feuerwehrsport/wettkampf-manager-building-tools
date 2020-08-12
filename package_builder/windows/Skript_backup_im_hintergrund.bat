@ECHO OFF

PUSHD %~dp0.
SET ROOT_DIR=%CD%
POPD

SET PATH=%ROOT_DIR%\ruby\bin;%ROOT_DIR%\ruby\lib\ruby\gems\2.6.0\bin;%PATH%
SET RAILS_ENV=production

PUSHD %ROOT_DIR%\wettkampf-manager
bundle exec rake backup_data_recurring
POPD

PAUSE