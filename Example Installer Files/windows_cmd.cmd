@echo off
cls
setlocal


:: Variables to set for your program:
:: - source_code_url: For example GitHub URL for the user to see the program's code
:: - program_size: The estimated disk space for a full  installation of your program
:: - python_release_url: The URL to the python release page (like: https://www.python.org/downloads/release/python-3128/)
:: - python_zip_download_url: The URL of the "windows embeddable package (64-bit)" on the release page of the python version.
:: - requirements_file_url: The URL to your requirements.txt file (only the modules which the initial file needs). Leave empty if not needed.
:: - initial_file_url: The URL for the file which should be downloaded and run. This could be an updater or an installer written in python.
:: ATTENTION: Every "%" in all URLs has to be replaced with "%%", otherwise it will not work.
set "program_name=..."
set "source_code_url=..."
set "program_size=..."
set "python_release_url=..."
set "python_zip_download_url=..."
set "requirements_file_url=..."
set "initial_file_url=..."


:: Different colors:
:: - ca = answer color, used for the user's answers to the questions
:: - ce = error color, used for all errors
:: - cf = file color, used for files and filepaths.
:: - ci = information color, used for all the information of other scripts (like the python output)
:: - cl = link color, used for URLs
:: - cm = main color, used for most information
:: - cq = question color, used for questions which the user needs to answer
:: - cr = reset color, used to reset all color codes
set "ca=[37m"
set "ce=[31m"
set "cf=[33m"
set "ci=[90m"
set "cl=[34m"
set "cm=[36m"
set "cq=[96m"
set "cr=[0m"


:: Display installer information and ask for permission to download files
title %program_name% Installer
echo.
echo %cm%This is the installer for %program_name%.
echo The source code is available under %cl%%source_code_url%
echo %cm%The program needs about %program_size% of free space.
echo.
echo.
echo The installer will download Python and PIP from the following URLs:
echo 1. %cl%%python_release_url% %cm%
echo 2. %cl%https://bootstrap.pypa.io/get-pip.py %cm%
echo Python and PIP will be installed in a separate directory only for this program.
echo.
echo The installer will also download the following files for the program to be installed correctly:
echo 1. %cl%%requirements_file_url% %cm%
echo 2. %cl%%initial_file_url% %cm%
echo.


:: Ask for permission to download files from the internet
:askConsent
echo.
set /p userPermission=%cq%Do you agree to proceed with the download? (yes/no): %ca%
if /I "%userPermission%"=="y" goto UserPermission
if /I "%userPermission%"=="Y" goto UserPermission
if /I "%userPermission%"=="yes" goto UserPermission
if /I "%userPermission%"=="Yes" goto UserPermission
if /I "%userPermission%"=="n" goto noUserPermission
if /I "%userPermission%"=="N" goto noUserPermission
if /I "%userPermission%"=="no" goto noUserPermission
if /I "%userPermission%"=="No" goto noUserPermission
echo Invalid input. Please enter "yes" or "no".
goto askConsent

:UserPermission

:: Ask for Installation Directory. The default is the user's program directory.
set "defaultPath=%LOCALAPPDATA%\Programs\%program_name%"

:askInstallationPath
echo.
set /p installPath=%cq%Enter the installation path or leave empty for default (default: %cf%%defaultPath%%cq%): %ca%
if "%installPath%"=="" set "installPath=%defaultPath%"


:: Ask for confirmation if it is not the default path
if /I "%installPath%" NEQ "%defaultPath%" goto customPathConfirmation


:correctPath

:: Check if the path contains either files or folders. If the path doesn't exist then also create a directory.
for %%i in ("%installPath%\*") do goto directoryNotEmpty
for /D %%i in ("%installPath%\*") do goto directoryNotEmpty
if not exist "%installPath%" mkdir "%installPath%"


:: Download the Python zip file
echo.
echo %cm%Downloading Python zip file from %cl%%python_zip_download_url% %ci%
set "pythonZipPath=%installPath%\python_downloaded.zip"
curl -o "%pythonZipPath%" "%python_zip_download_url%" -s
if errorlevel 1 goto downloadError


:: Unpack the zip file into a directory and delete the file.
echo.
echo %cm%Unpacking Python zip file %ci%
set "pythonUnpackDir=%installPath%\python"
mkdir "%pythonUnpackDir%"
tar -xf "%pythonZipPath%" -C "%pythonUnpackDir%"
if errorlevel 1 goto unpackError
del "%pythonZipPath%"


:: Download "get-pip.py"
echo.
echo %cm%Downloading %cf%get-pip.py %ci%
set "getPipUrl=https://bootstrap.pypa.io/get-pip.py"
set "getPipPath=%installPath%\get-pip.py"
curl -o "%getPipPath%" "%getPipUrl%" -s
if errorlevel 1 goto downloadError


:: Execute "get-pip.py" and remove it afterwards
echo.
echo %cm%Installing pip using the file %cf%get-pip.py %ci%
set "pythonExe=%installPath%\python\python.exe"
"%pythonExe%" "%getPipPath%" --no-warn-script-location
if errorlevel 1 goto executionError
del "%getPipPath%"


:: Find the "python---._pth" file. This has to be done using a search for the file extension because the name contains the actual version
echo.
echo %cm%Modifying the %cf%python._pth %cm%file to allow usage of PIP %ci%
for %%F in (%pythonUnpackDir%\*._pth) do set "pthFile=%%F"
if not defined pthFile goto fileNotFoundError


:: Change the "python---._pth" file to be able to use PIP.
for /f "usebackq tokens=*" %%A in ("%pthFile%") do (
    echo %%A | findstr /c:"#import site" >nul && (
        echo import site>>"%pthFile%.tmp"
    ) || (
        echo %%A>>"%pthFile%.tmp"
    )
)
move /y "%pthFile%.tmp" "%pthFile%" >nul
if errorlevel 1 goto fileModifyError


:: Check if there is a requirements_file_url
if "%requirements_file_url%"=="" goto noRequirementsFileNeeded


:: Download the requirements file using the filename from the URL
echo.
echo %cm%Downloading the requirements file from %cl%%requirements_file_url% %ci%
curl "%requirements_file_url%" --output-dir "%installPath%" -O -s
if errorlevel 1 goto downloadError


:: Get the filename from the downloaded file and set the filepath
timeout /t 1 /nobreak > nul
for /f "delims=" %%f in ('dir %installPath% /b /a-d /od') do (
    set "requirementsFileName=%%f"
)
set "requirementsPath=%installPath%\%requirementsFileName%"
if errorlevel 1 goto getFileNameError


:: Install the requirements from the requirements file
echo.
echo %cm%Installing requirements from %cf%%requirementsFileName% %ci%
"%pythonExe%" -m pip install -r "%requirementsPath%" --no-warn-script-location
if errorlevel 1 goto executionError


:noRequirementsFileNeeded

:: Download the initial file using the filename from the URL
echo.
echo %cm%Downloading the initial file from %cl%%initial_file_url% %ci%
curl "%initial_file_url%" --output-dir "%installPath%" -O -s
if errorlevel 1 goto downloadError


:: Get the filename from the downloaded file and set the filepath
timeout /t 1 /nobreak > nul
for /f "delims=" %%f in ('dir %installPath% /b /a-d /od') do (
    set "initialFileName=%%f"
)
set "initialFilePath=%installPath%\%initialFileName%"
if errorlevel 1 goto getFileNameError


:: Final message
echo.
echo %cm%After the next step the installation process is completed.
echo.
echo The program is stored at %cf%%installPath%
echo.
echo %cm%You can now follow further instructions from the program if there are any, otherwise you can close this window.


:: Execute the initial file.
echo.
echo %cm%Executing %cf%%initialFileName% %cr%
"%pythonExe%" "%initialFilePath%" --no-warn-script-location
if errorlevel 1 goto executionError


goto end


:: Jump points which can't be put in the middle of the script
:: Functions
:customPathConfirmation
echo.
echo %cm%You entered a custom installation path: %cf%%installPath%
set /p confirmPath=%cq%Is this path correct (no typos)? (yes/no): %ca%
if /I "%confirmPath%"=="y" goto correctPath
if /I "%confirmPath%"=="Y" goto correctPath
if /I "%confirmPath%"=="yes" goto correctPath
if /I "%confirmPath%"=="Yes" goto correctPath
if /I "%confirmPath%"=="n" goto askInstallationPath
if /I "%confirmPath%"=="N" goto askInstallationPath
if /I "%confirmPath%"=="no" goto askInstallationPath
if /I "%confirmPath%"=="No" goto askInstallationPath
echo Invalid input. Please enter "yes" or "no".
goto customPathConfirmation


:: Error Jump points
:directoryNotEmpty
echo.
echo %ce%The selected installation directory is not empty.
echo This could be due to the program already being installed.
echo Please choose an empty directory.
goto askInstallationPath


:downloadError
echo.
echo %ce%An error occurred while trying to download this file.
goto termination


:executionError
echo.
echo %ce%An error occurred while trying to execute this command.
goto termination


:fileModifyError
echo.
echo %ce%An error has occurred while trying to modify the content of this file.
goto termination


:fileNotFoundError
echo.
echo %ce%This file couldn't be found.
goto termination


:getFileNameError
echo.
echo %ce%Couldn't get the name of the downloaded file.
goto termination


:noUserPermission
echo.
echo %ce%Installation terminated since no consent to download was given.
echo If this was done by accident, execute the installer again.
goto end


:unpackError
echo.
echo %ce%An error occurred while trying to unpack the python interpreter.
goto termination


:: End jump points
:termination
echo %ce%Installation Terminated.
echo.
echo The Script was terminated due to an error.
echo To try to install this again please delete the contents of the directory at %installPath%
goto end


:end
echo.
pause

endlocal
