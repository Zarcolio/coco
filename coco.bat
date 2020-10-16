@ECHO OFF
CHCP 65001>NUL
ECHO:
ECHO === ( ͡° ͜ʖ ͡°) ============================================
ECHO =            Watch out! Hot coco overhere!!!            =
ECHO ============================================ ( ͡° ͜ʖ ͡°) ===
ECHO:
CHCP 437>NUL

:startbat
	IF "%1"=="backup" 		GOTO backup
	IF "%1"=="restore" 		GOTO restore
	IF "%1"=="cleanup"		GOTO cleanup
	IF "%1"=="setup"		GOTO setup
	IF "%1"=="installed"		GOTO installed
	IF "%1"=="" 			GOTO help
	IF "%1"=="-h" 			GOTO help
	IF "%1"=="help" 		GOTO help
	IF "%1"=="-?" 			GOTO help
	IF "%3"=="-y" 			SET opt=%3
	IF "%1"=="reinstall"	GOTO reinstall
	REM And else:
	GOTO :invalid

:help
	ECHO COCO is a set of customizations to Chocolatey.
	ECHO For suggestions, you can reach me @zarcolio on Twitter or Github.
	ECHO:
	ECHO Usage:
	ECHO:
	ECHO  COCO backup [batch] 		Creates a backup of installed packages to text (default) or batch file.
	ECHO  COCO cleanup			Cleans the Chocolatey environment from temp and other useless files.
	ECHO  COCO [help^|-h]			Displays help text.
	ECHO  COCO installed [^<package^>]	Lists which packages have been installed.
	ECHO  COCO reinstall ^<package^> [-y]	Reinstall this package by uninstalling and installing this package.
	ECHO  COCO restore ^<file^> 		Restore a backup from file.
	ECHO  COCO setup			Sets up Coco (installs choco-cleaner and Coco itself).
	IF %0 EQU "%~dpnx0" ECHO:
	IF %0 EQU "%~dpnx0" PAUSE
	GOTO exitbat

:backup
	IF "%2"=="batch" GOTO backupbatch
	FOR /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set datetime=%%G
	SET DateOnly=%datetime:~0,8%
	DIR /B "%ProgramData%\chocolatey\lib">"%userprofile%\documents\Choco_Pkg_%DateOnly%.txt"
	IF ERRORLEVEL 0 ECHO Backup to text file succesful.
	IF ERRORLEVEL 0 GOTO exitbat
	ECHO Backup not succesful.

:backupbatch
	FOR /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set datetime=%%G
	SET DateOnly=%datetime:~0,8%
	DIR /b "%ProgramData%\chocolatey\lib">"%userprofile%\documents\Choco_Pkg_%DateOnly%.txt"
	ECHO @ECHO OFF>"%userprofile%\documents\Choco_Pkg_%DateOnly%.bat"
	ECHO ECHO Coco is about to reinstall the packages in %%0.>>"%userprofile%\documents\Choco_Pkg_%DateOnly%.bat"
	ECHO ECHO Do you want to continue? Hit Ctrl-C to quit.>>"%userprofile%\documents\Choco_Pkg_%DateOnly%.bat"
	ECHO ECHO.>>"%userprofile%\documents\Choco_Pkg_%DateOnly%.bat"
	ECHO PAUSE>NUL>>"%userprofile%\documents\Choco_Pkg_%DateOnly%.bat"


	FOR /F %%f in (Choco_Pkg_%DateOnly%.txt) do echo choco install %%f -y>>"%userprofile%\documents\Choco_Pkg_%DateOnly%.bat"
	IF ERRORLEVEL 0 ECHO Backup to batch file succesful.
	IF ERRORLEVEL 0 GOTO exitbat
	ECHO Backup not succesful.

:restore
	IF "%2"=="" ECHO ERROR: File name is needed.
	IF "%2"=="" ECHO:
	IF "%2"=="" GOTO help
	IF NOT EXIST "%2" ECHO File not found.
	IF NOT EXIST "%2" GOTO exitbat
	
	ECHO Coco is about to reinstall the packages in "%2".
	ECHO Do you want to continue? Hit Ctrl-C to quit.
	PAUSE>NUL
	FOR /F "tokens=* delims=" %%x in (%2) DO choco install -y %%x
	GOTO exitbat

:cleanup
	CALL choco-cleaner.bat
	GOTO exitbat

:setup
	CHOCO install choco-cleaner -y
	COPY "%~dpxn0" "%ProgramData%\chocolatey\bin"
	GOTO exitbat

:reinstall
	IF "%2"=="" ECHO ERROR: Package name is needed.
	IF "%2"=="" ECHO:
	IF "%2"=="" GOTO help
	CHOCO uninstall %2 %opt%
	CHOCO install %2 %opt%
	GOTO exitbat

:installed
	IF NOT "%2"=="" SET InstalledFind=^|FIND /i "%2"
	DIR /B "%ProgramData%\chocolatey\lib"%InstalledFind%
	SET InstalledFind=
	GOTO exitbat

:invalid
	ECHO ERROR: Invalid parameters detected.
	ECHO:
	GOTO help	

:exitbat