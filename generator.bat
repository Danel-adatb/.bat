@echo off
setlocal EnableExtensions EnableDelayedExpansion

:PromptName
set "FileName="
echo/
set /P "FileName=Enter a name: "

rem Has the user entered anything at all?
if not defined FileName goto PromptName

rem Remove all double quotes from file name string?
set "FileName=!FileName:"=!"

rem Is the file name string now an empty string?
if not defined FileName goto PromptName

rem The string can be still invalid as file name. So check on
rem first file creation if the file could be created successfully.
(set /P FileNumber=<nul >"!FileName!01.mme") 2>nul
rem writing into that file
FOR /F "tokens=* delims=" %%x in (contents/c1.txt) DO echo %%x>> %FileName%01.mme
echo Customer test ref. number   :%FileName%01>> %FileName%01.mme
FOR /F "tokens=* delims=" %%x in (contents/c2.txt) DO echo %%x>> %FileName%01.mme

if not exist "%FileName%01.mme" (
    echo/
    echo The string !FileName! is most likely not valid for a file name.
    goto PromptName
)

:PromptNumber
set "FileNumber="
echo/
set /P "FileNumber=Enter a number in range 1 to 99: "

rem Has the user entered anything at all?
if not defined FileNumber goto PromptNumber

rem Has the file number string any other character than digits?
for /F "delims=0123456789" %%I in ("!FileNumber!") do (
    echo/
    echo !FileNumber! is not a valid decimal number.
    goto PromptNumber
)

rem It is safe now to reference the file number consisting
rem only of digits 0-9 without usage of delayed expansion.

rem Has the file number more than two digits?
if not "%FileNumber:~2%" == "" (
    echo/
    echo %FileNumber% has more than two digits.
    goto PromptNumber
)

rem Remove first digit of number if the number has two digits and
rem the first digit is 0 to get the number later always interpreted
rem as expected as decimal number and not as octal number.


if not "%FileNumber:~1%" == "" if "%FileNumber:~0,1%" == "0" (
	set "FileNumber=%FileNumber:~1%"
)
	

rem The file number is now in range 0 to 99. But 0 is not allowed.
if "%FileNumber%" == "0" (
    echo/
    echo Number 0 is not in valid range.
    goto PromptNumber
)

rem Create the remaining files. The first one was created already before.
cd /d "%~dp0"
for /L %%I in (1,1,%FileNumber%) do (
	for /d %%d in (.) do (
		if %%I LSS 10 (
			set "folder=%%~d/%FileName%0%%I"
		) else (
			set "folder=%%~d/%FileName%%%I"
		)
		
		if exist "!folder!" (
			if not exist "!folder!\" echo "!folder!" exists as a file! 1>&2
		) else (
	    md "!folder!"
		
		)
	)
)

echo Create "%FileName%01.mme"
rem Generating files
for /L %%I in (2,1,%FileNumber%) do (
	if %%I LSS 10 (
		echo Create "%FileName%0%%I.mme" 2>"%FileName%0%%I.mme"
	) else (
		echo Create "!FileName!%%I.mme" 2>"!FileName!%%I.mme"
	)

	rem writing into that file
	if %%I LSS 10 (
		FOR /F "tokens=* delims=" %%x in (contents/c1.txt) DO echo %%x>> %FileName%0%%I.mme
		echo Customer test ref. number   :%FileName%0%%I>> %FileName%0%%I.mme
		FOR /F "tokens=* delims=" %%x in (contents/c2.txt) DO echo %%x>> %FileName%0%%I.mme
	) else (
		FOR /F "tokens=* delims=" %%x in (contents/c1.txt) DO echo %%x>> !FileName!%%I.mme
		echo Customer test ref. number   :!FileName!%%I>> !FileName!%%I.mme
		FOR /F "tokens=* delims=" %%x in (contents/c2.txt) DO echo %%x>> !FileName!%%I.mme
	)
) 

rem moving the created files into their places
cd /d "%~dp0"
for /f "eol=: delims=" %%f in ('dir /b /a-d *^|findstr /live ".bat"') do (
    move /y "%%f" "%%~nf\"
)

endlocal
pause