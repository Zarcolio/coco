@ECHO OFF
chcp 65001>NUL
ECHO:
ECHO === ( ͡° ͜ʖ ͡°) ============================================
ECHO =            Watch out! Hot coco overhere!!!            =
ECHO ============================================ ( ͡° ͜ʖ ͡°) ===
ECHO:
chcp 437>NUL

:startbat
	IF "%1"=="backup" 		GOTO backup
	IF "%1"=="restore" 		GOTO restore
	IF "%1"=="cleanup"		GOTO cleanup
	IF "%1"=="setup"		GOTO setup
	IF "%1"=="" 			GOTO help
	IF "%1"=="-h" 			GOTO help
	IF "%1"=="-?" 			GOTO help
	IF "%2"=="" 			GOTO help
	IF "%3"=="-y" 			SET opt=%3
	IF "%1"=="reinstall"	GOTO reinstall
	REM And else:
	GOTO :help

:help
	ECHO COCO is a set of customizations to Chocolatey.
	ECHO For suggestions, you can reach me @zarcolio on Twitter or Github.
	ECHO:
	ECHO Usage:
	ECHO:
	ECHO  COCO backup 			Creates a backup in the form of a batch file.
	ECHO  COCO cleanup			Cleans the Chocolatey environment from temporary and other useless files.
	ECHO  COCO setup			Sets up Coco (installs choco-cleaner)
	ECHO  COCO reinstall ^<package^> [-y]	Reinstall this package by uninstalling and installing this package.
	GOTO exitbat

:backup
	FOR /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set datetime=%%G
	SET DateOnly=%datetime:~0,8%
	dir /b "%ProgramData%\chocolatey\lib">"%userprofile%\documents\Choco_Pkg_%DateOnly%.txt"
	IF ERRORLEVEL 0 ECHO Backup succesful.
	IF ERRORLEVEL 0 GOTO exitbat
	ECHO Backup not succesful.

:restore
	IF "%2"=="" ECHO Filename is needed.
	IF "%2"=="" GOTO exitbat
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
	
	GOTO exitbat

:reinstall
	choco uninstall %2 %opt%
	choco install %2 %opt%
	GOTO exitbat
	
:exitbat