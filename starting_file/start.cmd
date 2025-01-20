:: A template for this code can be found at https://github.com/shueppin/Python-App-Installer/blob/main/starting_file/start.cmd

@echo off
cls
setlocal


:: These values are set by the installer, but they can be changed if needed.
set "debug=false"
set "show_console=$show_console$"
set "start_file=$start_file$"
set "arguments=$arguments$"
set "source_code_url=$source_code_url$"
set "program_name=$program_name$"
set "log_file=%~dp0\log.txt"


title Start %program_name%

:: Set the time and date
for /f "tokens=*" %%d in ('date /t') do (set actualDate=%%d)
for /f "tokens=*" %%t in ('time /t') do (set actualTime=%%t)


:: Debug mode
if /I "%debug%"=="true" (
    :: Show some info to the log file
    echo. >> %log_file%
    echo. >> %log_file%
    echo The starting script for %program_name% was executed at %actualDate%%actualTime% in DEBUG mode >> %log_file%
    echo. >> %log_file%

    :: Show some info to the console
    echo DEBUG is activated
    echo.
    echo Source code for %program_name% script can be found at %source_code_url%
    echo The log file can be found at %log_file%
    echo.
    echo Variables:
    echo show_console = "%show_console%"
    echo start_file = "%start_file%"
    echo arguments = "%arguments%"
    echo.
    echo Starting with console open
    echo.

    start "%program_name%" "%~dp0\python\python.exe" "%start_file%" %arguments% 2>> %log_file%

    pause

    goto end
)


:: Show some info to the log file
echo. >> %log_file%
echo. >> %log_file%
echo The starting script for %program_name% was executed at %actualDate%%actualTime% >> %log_file%
echo. >> %log_file%


:: Start the script either with or without console
if /I "%show_console%"=="true" (
    start "%program_name%" "%~dp0\python\python.exe" "%start_file%" %arguments% 2>> %log_file%
) else if /I "%show_console%"=="false" (
    :: It needs to be started like this in the background so the python output can be written to the log file.
    start /B "%program_name%" "%~dp0\python\pythonw.exe" %start_file% %arguments% >> %log_file% 2>&1
) else (
    :: If the variable is not set then output this to the console and just start the script with the console open
    echo Please set "show_console" either to "true" or to "false"
    timeout /t 5
    start "%program_name%" "%~dp0\python\python.exe" "%start_file%" %arguments% 2>> %log_file%
)


:end
:: Error handling
if errorlevel 1 (
    echo There was an error when trying to execute the given file.
    echo For support please go to %source_code_url%
    echo The cmd file has crashed >> %log_file%
    pause
)

endlocal
