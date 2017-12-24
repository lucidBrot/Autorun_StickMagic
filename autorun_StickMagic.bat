@echo off
::this should check if a stick is there with letter Q and if yes, execute the denoted option
::options:
::Start League patcher --lol--
::Start steam:  --steam--
::Start curse: --curse--

::Make sure to sign the command file with (A1A4E7B9)
::....................................................................
:: gpg -a -b -o ./.stickmagic.sig -u eric@mink.li -s ./.stickmagic  ::
::....................................................................

::Make sure that stick is set to always have drive letter Q

REM set "debug=y"
set "debug=" #remove y to stop debug mode, add y after = to enter debug mode
REM REM SetLocal EnableDelayedExpansion
REM REM needed for for-loop, otherwise variable is evaluated at parse time.
if defined debug (echo "Testing if Q:\.stickmagic exists")
if not exist "Q:\.stickmagic" (
	if defined debug (echo "Could not find Q:\.stickmagic")
	if defined debug (echo "Failed.")
	exit /B 2
)
if not exist "Q:\.stickmagic.sig" (
	if defined debug (echo "Could not find Q:\.stickmagic.sig")
	if defined debug (echo "Failed.")
	exit /B 2
)
if defined debug (echo "verifying pgp signature...")
::disable any local variable called errorlevel
set "errorlevel="
::verify the signature
gpg --no-default-keyring --keyring "N:\Files\Schule\XCubby\storage\scripts\autorun_stickmagic\.stickmagic.pubkey.gpg" --status-fd 1 --verify "Q:\.stickmagic.sig" 2>nul
if %ERRORLEVEL% NEQ 0 (
	if %ERRORLEVEL% == 1 (
		if defined debug (echo "BAD SIGNATURE.")
	) else (
		if defined debug (echo "PGP ERROR.")
	)
	exit /B 4
) else (
	if defined debug (echo "Signature fine.")
	::read file lines
	for /f "tokens=*" %%a in ( Q:\\.stickmagic ) do (
		REM echo line=%%a
		REM start the corresponding tool
		REM double colons break syntax https://stackoverflow.com/questions/3978655/windows-batch-file-with-goto-command-not-working/4006006#4006006
		
		REM REM delayed expansion: https://stackoverflow.com/questions/28316069/if-condition-inside-for-loop-with-batch-file
		REM REM set b=%%a REM to use with !b! REM not needed actually...
		if "%%a" == "--lol--" (
			if defined debug (echo "starting lol")
			start F:\Programme\Games\LoL\LeagueClient.exe
		) else if "%%a" == "--curse--" (
			if defined debug (echo "starting curse")
			REM avoiding a bug in start where quotes are removed
			cd /d "C:\Users\Eric\AppData\Roaming\Curse Client\Bin"
			start ./Twitch.exe
			if defined debug ( echo "don't trust the current dir anymore." )
			REM REM REM start "C:\Users\Eric\AppData\Roaming\Curse Client\Bin\Twitch.exe"
		) else if "%%a" == "--steam--" (
			if defined debug (echo "starting steam")
			start F:\Programme\Games\Steam\Steam.exe 
			REM setting these paths in quotes does NOT work
		) else (
			if defined debug ( echo %%a did not fit any pattern )
		)
	)
)
if defined debug ( pause ) else ( exit /B 0 )