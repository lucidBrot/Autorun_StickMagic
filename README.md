# Autorun StickMagic

A hacked-together batch script for the following scenario:

> Starting up the computer takes a few precious seconds. In the old days that would be long enough to go get a coffee, but that's not the case anymore. And once the PC booted up, you need to be present to launch your desired program and then wait again while they're starting up. You could of course put them into the autorun directory, but that would make *every* startup slower and you would have to close them manually again.
> **What if you could tell your computer which tools it should run *before* you press the start button?**

This script (when run, e.g. from autostart) checks if a usb-stick is inserted that has the fixed drive-letter `Q:\\` assigned. If yes, it reads the file `Q:\\.stickmagic` and maps every line within it to a program.

I have one USB-stick for starting Steam and one stick for launching both League of Legends and Twitch Voice for example. It isn't hard to change those mappings, even though they are hard-coded.

Mappings

The mappings are checked with a simple for loop. Use full paths for your own safety.

```batch
for /f "tokens=*" %%a in ( Q:\\.stickmagic ) do (
		if "%%a" == "--lol--" (
			if defined debug (echo "starting lol")
			start F:\Programme\Games\LoL\LeagueClient.exe
		) else if "%%a" == "--curse--" (
			if defined debug (echo "starting curse")
			REM avoiding a bug in start where quotes are removed by 'start', which is a problem if there is a space in the path.
			cd /d "C:\Users\LeMe\AppData\Roaming\Curse Client\Bin"
			start ./Twitch.exe
			if defined debug ( echo "don't trust the current dir anymore." )
			REM REM REM (buggy microsoft) REM start "C:\Users\LeMe\AppData\Roaming\Curse Client\Bin\Twitch.exe"
		) else if "%%a" == "--steam--" (
			if defined debug (echo "starting steam")
			start F:\Programme\Games\Steam\Steam.exe 
			REM setting these paths in quotes does NOT work
		) else (
			if defined debug ( echo %%a did not fit any pattern )
		)
	)
```

An example `.stickmagic` file:

```
--lol--
--steam--
--curse--
```

So to add your own programs, edit the code I pasted above in `autorun_StickMagic.bat` accordingly. If your path contains spaces, hold to the example of the Curse Client case.

## Security Considerations

Executing code that somebody puts on a stick and plugs into your PC is generally a bad idea. Here, I assume that you need to be logged in and have hardware-access to plug the stick in anyways, so it's not *that* bad. But to prevent scenarios like somebody plugging in their stick with malicious programs on it, I added two things.

1. The stick does not contain executables that will be automatically run. Only mappings to predefined executables. If somebody were to have access to your computer and change the code of the StickMagic batch file or of your pre-specified executable, then your computer was already compromised anyway.
2. The StickMagic script checks whether there exists a file `Q:\\.stickmagic.sig` which contains a valid gpg signature for the `.stickmagic` file. The public key corresponding to this signature must be contained in the `.stickmagic.pubkey.gpg` file in the directory specified in the `autorun_StickMagic.bat` script file. See [the Instructions](#setup) for more info.

## Setup

1. Download the `autorun_StickMagic.bat` file
2. Make sure you have `gpg` installed and set up
3. Generate a `.stickmagic.pubkey.gpg` file with the command `gpg --export A1A4E7B9 > .stickmagic.pubkey.gpg` 
   where A1A4E7B9 is the key ID of the key you want to use to sign your settings.
   *Note:* Do not armor this key (`-a` flag)
4. Set up a USB-Stick by assigning it a permanent drive letter in the windows settings. `Q:` by default.
5. Open `autorun_StickMagic.bat` with a text editor and replace any paths that reference `Q:` with the equivalent for your chosen drive letter.
6. Clean up the code in the for loop on line 45 (which was pasted [here](#mappings)) and modify it to fit your needs. Every string of the format`--asdfasjdfasdf--` can be replaced by whatever string you want to use. Add the program pathes you want to be possible to be started by StickMagic.
7. Replace my path to `.stickmagic.pubkey.gpg` (still in the StickMagic script file) with yours.
8. Create a file in the root of your stick, call it `.stickmagic` and enter every string on a new line. (See [Mappings](#mappings))
9. Create a signature file by entering this command in the root directory of your stick.
   `gpg -a -b -o ./.stickmagic.sig -u your@gpgUI.com -s ./.stickmagic`
   Here, *your@gpgUI.com*  should be whatever UserID your key has (the one from step 3).
10. Try if everything works as intended by running `autorun_StickMagic.bat`. If everything is fine, put that file into your windows autorun directory.
11. Profit: Unplug your stick, shutdown your PC. Next time you can plug the stick in, press the power button, walk away and when you come back, your preferred programs will have started.

## Disclaimer

This was made in a short time with few time invested in usability and testing. Any bugs and security problems are your own responsibility - read the code if you care enough. I provide this script as-is without any guarantees whatsoever. If you want to use this script for yourself, feel free to just take it. If you want to redistribute it or use it commercially, please contact me.