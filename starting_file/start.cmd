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


:: Debug mode
if /I "%debug%"=="true" (
    echo DEBUG is activated
    echo.
    echo Source code for %program_name% script can be found at %source_code_url%
    echo.
    echo Variables:
    echo show_console = "%show_console%"
    echo start_file = "%start_file%"
    echo arguments = "%arguments%"
    echo.
    echo Starting with console open
    echo.

    start "%program_name%" "python\python.exe" "%start_file%" %arguments%

    pause

    goto end
)


:: Start the script either with or without console
if /I "%show_console%"=="true" (
    start "%program_name%" "python\python.exe" "%start_file%" %arguments%
) else if /I "%show_console%"=="false" (
    start "%program_name%" "python\pythonw.exe" "%start_file%" %arguments%
) else (
    :: If the variable is not set then output this to the console and just start the script with the console open
    echo Please set "show_console" either to "true" or to "false"
    timeout /t 5
    start "%program_name%" "python\python.exe" "%start_file%" %arguments%
)


:end
:: Error handling
if errorlevel 1 (
    echo There was an error when trying to execute the given file.
    echo For support please go to %source_code_url%
    pause
)

endlocal
