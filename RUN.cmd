@echo off
SET LOCAL EnableDelayedExpansion
cls
set "DIR=%cd%"
REM PRE-SCRIPT WORK - GETTING IP AND SETTING TO VARIABLE.
nslookup myip.opendns.com resolver1.opendns.com | find "Address" >"%temp%\ip1.txt"
more +1 "%temp%\ip1.txt" >"%temp%\ip2.txt"
del %temp%\ip1.txt
set /p IP=<%temp%\ip2.txt
del %temp%\ip2.txt
set IP=%IP:~10%
cls
REM SETTING CPU INFO
set "OUTFOLDER=%DIR%\CPULogs\"
set "OUTFILE=%OUTFOLDER%\[%NUMBER_OF_PROCESSORS%]CRS-%IP%.txt"
cls
REM STARTING THE REPORT PART OF THE SCRIPT
if NOT EXIST "%OUTFOLDER%" mkdir "%OUTFOLDER%" >NUL
IF NOT EXIST "%OUTFOLDER%\!CORES-IPADDRESSES.txt" echo This is just a Placeholder in the CPULogs Directory. > %OUTFOLDER%\!CORES-IPADDRESSES.txt
wmic CPU get Name,NumberOfCores,NumberOfLogicalProcessors >%OUTFOLDER%\cores.txt
wmic path Win32_PerfFormattedData_PerfProc_Process get Name,PercentProcessorTime >%OUTFOLDER%\output.txt
echo. >>%OUTFOLDER%\output.txt
echo powershell.exe -executionpolicy bypass ".\CPULogs\refine.ps1" >%OUTFOLDER%\clean.bat
echo Get-Content .\CPULogs\output.txt ^|?{ ^$_ -notmatch '  0' } ^| Out-File 'CPULogs\output2.txt' >%OUTFOLDER%\refine.ps1
call "%OUTFOLDER%\clean.bat"
echo Pausing 10 seconds to Start CPU REPORT Script.
timeout /t 10 /NOBREAK>NUL
REM COPYING REPORT TOGETHER
echo Generating Report..
echo CPU Report: > %OUTFOLDER%\final.txt
type "%OUTFOLDER%\cores.txt" >> %OUTFOLDER%\final.txt
del /f "%OUTFOLDER%\cores.txt"
echo. >> %OUTFOLDER%\final.txt
echo. >> %OUTFOLDER%\final.txt
echo CPU Usage Processes: >> %OUTFOLDER%\final.txt
type "%OUTFOLDER%\output2.txt" >> %OUTFOLDER%\final.txt
del /f "%OUTFOLDER%\output.txt"
del /f "%OUTFOLDER%\output2.txt"
copy "%DIR%\CPULogs\final.txt" "%OUTFILE%" >NUL
REM del /f "%OUTFOLDER%\cpuinfo.txt"
del /f "%OUTFOLDER%\final.txt"
timeout /t 1 /NOBREAK >NUL
REM CLEANING UP FOR EXIT
del /f "%OUTFOLDER%\clean.bat"
del /f "%OUTFOLDER%\refine.ps1"
timeout /t 1 /NOBREAK>NUL
echo Done..
exit /B
