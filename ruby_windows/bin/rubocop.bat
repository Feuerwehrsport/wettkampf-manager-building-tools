@ECHO OFF
IF NOT "%~f0" == "~f0" GOTO :WinNT
echo "You need WIN NT"
rem @"C:\Ruby23\bin\ruby.exe" "C:/Ruby23/bin/rubocop" %1 %2 %3 %4 %5 %6 %7 %8 %9
GOTO :EOF
:WinNT
@"ruby.exe" "%~dpn0" %*
