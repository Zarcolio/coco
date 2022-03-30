@ECHO off
chcp 65001>nul
echo:
ECHO     ^| ????? ^|
ECHO === ( ? ?? ?? ) ============================================
ECHO =           watch out! hot cocoa overhere!!! ^| ????? ^|   =
ECHO ============================================ ( ? ?? ?? ) ===
echo:
chcp 437>nul

SET opt=
SET opt2=

:startbat
	IF /i "%1"=="backup" 		GOTO backup
	IF /i "%1"=="list"	 		GOTO list
	IF /i "%1"=="restore" 		GOTO restore
	IF /i "%1"=="cleanup"		GOTO cleanup
	IF /i "%1"=="setup"			GOTO setup
	IF /i "%1"=="installed"		GOTO installed
	IF /i "%1"=="" 				GOTO help
	IF /i "%1"=="-h" 			GOTO help
	IF /i "%1"=="help" 			GOTO help
	IF /i "%1"=="-?" 			GOTO help
	IF /i "%3"=="-y" 			SET opt=%3
	IF /i "%3"=="-y" 			SET opt2=/q
	IF /i "%1"=="reinstall"		GOTO reinstall
	IF /i "%1"=="update"		GOTO update
	rem and else:
	GOTO :invalid

:help
	ECHO cocoa is a SET of customizations to chocolatey.
	ECHO FOR suggestions, you can reach me @zarcolio on twitter or github.
	echo:
	ECHO usage:
	echo:
	ECHO  cocoa backup [batch] 			creates a backup of installed packages to text (default) or batch file.
	ECHO  cocoa cleanup				cleans the chocolatey environment from temp and other useless files.
	ECHO  cocoa [help^|-h]			displays help text.
	ECHO  cocoa installed [^<package^>]		lists which packages have been installed.
	ECHO  cocoa list [^<package^>]			lists which packages are available and not broken (differs from "choco list").
	ECHO  cocoa reinstall ^<package^> [-y]		reinstall this package by uninstalling and installing this package.
	ECHO  cocoa restore ^<file^> 			restore a backup from file.
	ECHO  cocoa setup				sets up cocoa (installs choco-cleaner and cocoa itself).
	ECHO  cocoa update [-y]			updates all packages but only shows updated packages. Also take in account whether Controlled Folder Access is enabled.
	IF %0 equ "%~dpnx0" (
		echo:
		pause
	)
	GOTO exitbat

:backup
	IF "%2"=="batch" GOTO backupbatch
	FOR /f "tokens=2 delims==" %%g in ('wmic os get localdatetime /value') do SET datetime=%%g
	SET dateonly=%datetime:~0,8%
	dir /b "%programdata%\chocolatey\lib">"%userprofile%\documents\choco_pkg_%dateonly%.txt"
	IF errorlevel 0 (
		ECHO backup to text file succesful.
		GOTO exitbat
	)
	ECHO backup not succesful.

:backupbatch
	FOR /f "tokens=2 delims==" %%g in ('wmic os get localdatetime /value') do SET datetime=%%g
	SET dateonly=%datetime:~0,8%
	dir /b "%programdata%\chocolatey\lib">"%userprofile%\documents\choco_pkg_%dateonly%.tmp"
	ECHO @ECHO off>"%userprofile%\documents\choco_pkg_%dateonly%.bat"
	ECHO ECHO cocoa is about to reinstall the packages in %%0.>>"%userprofile%\documents\choco_pkg_%dateonly%.bat"
	ECHO ECHO do you want to continue? hit ctrl-c to quit.>>"%userprofile%\documents\choco_pkg_%dateonly%.bat"
	ECHO echo.>>"%userprofile%\documents\choco_pkg_%dateonly%.bat"
	ECHO pause>nul>>"%userprofile%\documents\choco_pkg_%dateonly%.bat"


	FOR /f %%f in (%userprofile%\documents\choco_pkg_%dateonly%.tmp) do ECHO choco install %%f -y>>"%userprofile%\documents\choco_pkg_%dateonly%.bat"
	DEL %userprofile%\documents\choco_pkg_%dateonly%.tmp
	IF errorlevel 0 (
		ECHO backup to batch file succesful.
		GOTO exitbat
	)
	ECHO backup not succesful.

:restore
	IF "%2"=="" (
		ECHO error: file name is needed.
		echo:
		GOTO help
	)
	IF not exist "%2" (
		ECHO file not found.
		GOTO exitbat
	)
	
	ECHO cocoa is about to reinstall the packages in "%2".
	ECHO do you want to continue? hit ctrl-c to quit.
	pause>nul
	FOR /f "tokens=* delims=" %%x in (%2) do choco install -y %%x
	GOTO exitbat

:cleanup
	call choco-cleaner.bat
	powershell.exe -file %programdata%\chocolatey\bin\cocoa-packages.ps1 -cleanup
	GOTO exitbat

:setup
	choco install choco-cleaner -y
	powershell.exe -command invoke-webrequest https://raw.githubusercontent.com/zarcolio/cocoa/master/cocoa-packages.ps1 -o %programdata%\chocolatey\bin\cocoa-packages.ps1
	copy "%~dpxn0" "%programdata%\chocolatey\bin"
	IF %errorlevel% neq 0 exit /b 255
	GOTO exitbat

:reinstall
	IF "%2"=="" (
		ECHO error: package name is needed.
		echo:
		GOTO help
	)
	choco uninstall %2 %opt%
	DEL %opt2% %programdata%\chocolatey\lib\%2\
	choco install %2 %opt%
	GOTO exitbat

:update
	REG query "HKLM\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access" /v EnableControlledFolderAccess|find "0x1">NUL
	IF %errorlevel%==0 SET /p "DisableCFA=Controlled Folder Access (anti-ransomware) detected, temporarily disable [d], continue without disabling or [c]exit [e] ? "
	IF %errorlevel%==1 GOTO ExecuteCUP
	IF /i "%DisableCFA%"=="d" (
		powershell Set-MpPreference -EnableControlledFolderAccess Disabled
		ECHO Controlled Folder Access has been temporarily disabled...
		ECHO:
		SET CFA=disabled
		GOTO ExecuteCUP
	)
	IF /i "%DisableCFA%"=="e" GOTO ExitBat
	IF /i "%DisableCFA%"=="c" GOTO ExecuteCUP
	GOTO update
:ExecuteCUP
	cup all %opt%|find /v "is the latest version available based on your source(s)." |find /v "is newer than the most recent." | find /v "you must be smarter than the average bear..."
	IF "%CFA%"=="disabled" (
		powershell Set-MpPreference -EnableControlledFolderAccess Enabled
		SET CFA=
		ECHO:
		ECHO Controlled Folder Access has been re-enabled...
		ECHO:
	)
	GOTO exitbat

:installed
	IF /i "%2"=="-v" (
		powershell.exe -file %programdata%\chocolatey\bin\cocoa-packages.ps1 -list %installedfind%
		GOTO exitbat
	)
	IF not "%2"=="" SET installedfind=^|find /i "%2"
	IF /i not "%3"=="-v" dir /b "%programdata%\chocolatey\lib"%installedfind%
	IF /i "%3"=="-v" powershell.exe -file %programdata%\chocolatey\bin\cocoa-packages.ps1 -list %installedfind%
	SET installedfind=
	GOTO exitbat

:list
	IF not "%2"=="" (
		choco list %2|find /v /i "broken"|find /v /i "packages found."
		GOTO exitbat
	)

:invalid
	ECHO error: invalid parameters detected.
	echo:
	GOTO help	

:exitbat




