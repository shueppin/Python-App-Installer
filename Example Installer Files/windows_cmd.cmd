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


title %program_name% Installer
:: Display installer information and ask for permission to download files
echo.
echo This is the installer for %program_name%.
echo The source code is available under "%source_code_url%"
echo The program needs about %program_size% of free space.
echo.
echo.
echo The installer will download Python and PIP from the following URLs:
echo 1. %python_release_url%
echo 2. https://bootstrap.pypa.io/get-pip.py
echo They will only be installed for this program in a separate directory.
echo.
echo The installer will also download the following files for the program to be installed correctly:
echo 1. %requirements_file_url%
echo 2. %initial_file_url%
echo.


:: Ask for permission to download files from the internet
:askConsent
echo.
set /p userPermission=Do you agree to proceed with the download? (yes/no):
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
set /p installPath=Enter the installation path or leave empty for default (default: %defaultPath%):
if "%installPath%"=="" set "installPath=%defaultPath%"


:: Ask for confirmation if it is not the default path
if /I "%installPath%" NEQ "%defaultPath%" goto customPathConfirmation


:correctPath

:: Check if the path contains either files or folders. If the path doesn't exist then also create a directory.
for %%i in ("%installPath%\*") do goto directoryNotEmpty
for /D %%i in ("%installPath%\*") do goto directoryNotEmpty
if not exist "%installPath%" mkdir "%installPath%"


:: Download the Python zip file
set "pythonZipUrl=%python_zip_download_url%"
set "pythonZipPath=%installPath%\python_downloaded.zip"
echo.
echo Downloading Python zip file...
curl -o "%pythonZipPath%" "%pythonZipUrl%" -s
if errorlevel 1 goto downloadError


:: Unpack the zip file into a directory and delete the file.
set "pythonUnpackDir=%installPath%\python"
echo.
echo Unpacking Python zip file...
mkdir "%pythonUnpackDir%"
tar -xf "%pythonZipPath%" -C "%pythonUnpackDir%"
if errorlevel 1 goto unpackError
del "%pythonZipPath%"


:: Download "get-pip.py"
set "getPipUrl=https://bootstrap.pypa.io/get-pip.py"
set "getPipPath=%installPath%\get-pip.py"
echo.
echo Downloading "get-pip.py"...
curl -o "%getPipPath%" "%getPipUrl%" -s
if errorlevel 1 goto downloadError


:: Execute "get-pip.py" and remove it afterwards
set "pythonExe=%installPath%\python\python.exe"
echo.
echo Installing pip using the file "get-pip.py"...
"%pythonExe%" "%getPipPath%" --no-warn-script-location
if errorlevel 1 goto executionError
del "%getPipPath%"


:: Find the "python---._pth" file. This has to be done using a search for the file extension because the name contains the actual version
echo.
echo Searching for the "python._pth" file to allow usage of PIP...
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
echo Downloading the requirements file from %requirements_file_url%
curl "%requirements_file_url%" --output-dir "%installPath%" -O -s
if errorlevel 1 goto downloadError


:: Get the filename from the downloaded file and set the filepath
timeout /t 1 /nobreak > nul
for /f "delims=" %%f in ('dir %installPath% /b /a-d /od') do (
    set "requirementsFileName=%%f"
)
set "requirementsPath=%installPath%\%requirementsFileName%"
if errorlevel 1 goto getFileNameError
echo %requirementsPath%


:: Install the requirements from the requirements file
echo.
echo Installing requirements from "%requirementsFileName%"...
"%pythonExe%" -m pip install -r "%requirementsPath%" --no-warn-script-location
if errorlevel 1 goto executionError


:noRequirementsFileNeeded

:: Download the initial file using the filename from the URL
echo.
echo Downloading the initial file from %initial_file_url%
curl "%initial_file_url%" --output-dir "%installPath%" -O -s
if errorlevel 1 goto downloadError


:: Get the filename from the downloaded file and set the filepath
timeout /t 1 /nobreak > nul
for /f "delims=" %%f in ('dir %installPath% /b /a-d /od') do (
    set "initialFileName=%%f"
)
set "initialFilePath=%installPath%\%initialFileName%"
if errorlevel 1 goto getFileNameError
echo %initialFilePath%


:: Execute the initial file.
echo Executing "%initialFileName%"...
"%pythonExe%" "%initialFilePath%" --no-warn-script-location
if errorlevel 1 goto executionError


:: Final message
echo.
echo Installation process completed.
echo.
echo The program is stored at "%installPath%".
echo.
echo You can now follow further instructions from the program if there are any, otherwise you can close this window.
goto end


:: Jump points which can't be put in the middle of the script
:: Functions
:customPathConfirmation
echo.
echo You entered a custom installation path: %installPath%
set /p confirmPath=Is this path correct (no typos)? (yes/no):
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
echo The selected installation directory is not empty.
echo This could be due to the program already being installed.
echo Please choose an empty directory.
goto askInstallationPath


:downloadError
echo.
echo An error occurred while trying to download this file.
goto termination


:executionError
echo.
echo An error occurred while trying to execute this command.
goto termination


:fileModifyError
echo.
echo An error has occurred while trying to modify the content of this file.
goto termination


:fileNotFoundError
echo.
echo This file couldn't be found.
goto termination


:getFileNameError
echo.
echo Couldn't get the name of the downloaded file.
goto termination


:noUserPermission
echo.
echo Installation terminated since no consent to download was given.
echo If this was done by accident, execute the installer again.
goto end


:unpackError
echo.
echo An error occurred while trying to unpack the python interpreter.
goto termination


:: End jump points
:termination
echo Installation Terminated.
echo.
echo The Script was terminated due to an error.
echo To try to install this again please delete the contents of the directory at %installPath%
goto end


:end
echo.
pause

endlocal
