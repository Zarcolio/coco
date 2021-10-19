@echo off
chcp 65001>nul
echo:
echo     ^| ᶜᵒᶜᵒ ^|
echo === ( ° ͜ʖ ͡°) ============================================
echo =            Watch out! Hot coco overhere!!! ^| ᶜᵒᶜᵒ ^|   =
echo ============================================ ( ° ͜ʖ ͡°) ===
echo:
chcp 437>nul

set opt=
set opt2=

:startbat
	if /i "%1"=="backup" 		goto backup
	if /i "%1"=="restore" 		goto restore
	if /i "%1"=="cleanup"		goto cleanup
	if /i "%1"=="setup"		goto setup
	if /i "%1"=="installed"		goto installed
	if /i "%1"=="" 			goto help
	if /i "%1"=="-h" 			goto help
	if /i "%1"=="help" 		goto help
	if /i "%1"=="-?" 			goto help
	if /i "%3"=="-y" 			set opt=%3
	if /i "%3"=="-y" 		set opt2=/q
	if /i "%1"=="reinstall"	goto reinstall
	if /i "%1"=="update"	goto update
	rem and else:
	goto :invalid

:help
	echo coco is a set of customizations to chocolatey.
	echo for suggestions, you can reach me @zarcolio on twitter or github.
	echo:
	echo usage:
	echo:
	echo  coco backup [batch] 		creates a backup of installed packages to text (default) or batch file.
	echo  coco cleanup			cleans the chocolatey environment from temp and other useless files.
	echo  coco [help^|-h]			displays help text.
	echo  coco installed [^<package^>]	lists which packages have been installed.
	echo  coco reinstall ^<package^> [-y]	reinstall this package by uninstalling and installing this package.
	echo  coco restore ^<file^> 		restore a backup from file.
	echo  coco setup			sets up coco (installs choco-cleaner and coco itself).
	echo  coco update [-y]		updates all packages but only shows updated packages.
	if %0 equ "%~dpnx0" echo:
	if %0 equ "%~dpnx0" pause
	goto exitbat

:backup
	if "%2"=="batch" goto backupbatch
	for /f "tokens=2 delims==" %%g in ('wmic os get localdatetime /value') do set datetime=%%g
	set dateonly=%datetime:~0,8%
	dir /b "%programdata%\chocolatey\lib">"%userprofile%\documents\choco_pkg_%dateonly%.txt"
	if errorlevel 0 echo backup to text file succesful.
	if errorlevel 0 goto exitbat
	echo backup not succesful.

:backupbatch
	for /f "tokens=2 delims==" %%g in ('wmic os get localdatetime /value') do set datetime=%%g
	set dateonly=%datetime:~0,8%
	dir /b "%programdata%\chocolatey\lib">"%userprofile%\documents\choco_pkg_%dateonly%.txt"
	echo @echo off>"%userprofile%\documents\choco_pkg_%dateonly%.bat"
	echo echo coco is about to reinstall the packages in %%0.>>"%userprofile%\documents\choco_pkg_%dateonly%.bat"
	echo echo do you want to continue? hit ctrl-c to quit.>>"%userprofile%\documents\choco_pkg_%dateonly%.bat"
	echo echo.>>"%userprofile%\documents\choco_pkg_%dateonly%.bat"
	echo pause>nul>>"%userprofile%\documents\choco_pkg_%dateonly%.bat"


	for /f %%f in (choco_pkg_%dateonly%.txt) do echo choco install %%f -y>>"%userprofile%\documents\choco_pkg_%dateonly%.bat"
	if errorlevel 0 echo backup to batch file succesful.
	if errorlevel 0 goto exitbat
	echo backup not succesful.

:restore
	if "%2"=="" echo error: file name is needed.
	if "%2"=="" echo:
	if "%2"=="" goto help
	if not exist "%2" echo file not found.
	if not exist "%2" goto exitbat
	
	echo coco is about to reinstall the packages in "%2".
	echo do you want to continue? hit ctrl-c to quit.
	pause>nul
	for /f "tokens=* delims=" %%x in (%2) do choco install -y %%x
	goto exitbat

:cleanup
	call choco-cleaner.bat
	powershell.exe -file %programdata%\chocolatey\bin\coco-packages.ps1 -cleanup
	goto exitbat

:setup
	choco install choco-cleaner -y
	powershell.exe -command invoke-webrequest https://raw.githubusercontent.com/zarcolio/coco/master/coco-packages.ps1 -o %programdata%\chocolatey\bin\coco-packages.ps1
	copy "%~dpxn0" "%programdata%\chocolatey\bin"
	if %errorlevel% neq 0 exit /b 255
	goto exitbat

:reinstall
	if "%2"=="" echo error: package name is needed.
	if "%2"=="" echo:
	if "%2"=="" goto help
	choco uninstall %2 %opt%
	del %opt2% %programdata%\chocolatey\lib\%2\
	choco install %2 %opt%
	goto exitbat

:update
	cup all %opt%|find /v "is the latest version available based on your source(s)." |find /v "is newer than the most recent." | find /v "you must be smarter than the average bear..."
	goto exitbat

:installed
	if /i "%2"=="-v" powershell.exe -file %programdata%\chocolatey\bin\coco-packages.ps1 -list %installedfind%
	if /i "%2"=="-v" goto exitbat
	if not "%2"=="" set installedfind=^|find /i "%2"
	if /i NOT "%3"=="-v" dir /b "%programdata%\chocolatey\lib"%installedfind%
	if /i "%3"=="-v" powershell.exe -file %programdata%\chocolatey\bin\coco-packages.ps1 -list %installedfind%
	set installedfind=
	goto exitbat

:invalid
	echo error: invalid parameters detected.
	echo:
	goto help	

:exitbat
