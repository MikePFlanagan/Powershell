@echo off
NET SESSION >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    ECHO Administrator PRIVILEGES Detected! 
GOTO START
) ELSE (
    ECHO NOT AN ADMIN!
GOTO NOADMIN
)

:START
echo What would you like to do?
set /P A1=(U)Updates, (P)User Prep, OR (B)Both:
if "%A1%"=="u" GOTO UPDATE
if "%A1%"=="p" GOTO ADDADMIN
if "%A1%"=="b" GOTO UPDATE

:UPDATE
echo What TYPE of updates would you like to install?
set /P A2=(D)Dell/Lenovo Updates, (W)Windows Updates, OR (B)Both:
if "%A2%"=="d" GOTO OEMUPDATE
if "%A2%"=="w" GOTO WINDOWSUPDATE
if "%A2%"=="b" GOTO OEMUPDATE

:OEMUPDATE
Echo Killing existing instances of Dell command update and running if present.
taskkill /IM DellCommandUpdate.exe /F
"C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" /ApplyUpdates 
"C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" /ApplyUpdates
ECHO If system is Lenovo, now running Lenovo System Updater
"%PROGRAMFILES(x86)%\Lenovo\System Update\tvsu.exe"/CM -search R -action INSTALL -includerebootpackages 1,3,4 -nolicense -noicon
Echo Dell/Lenovo Updates completed
if "%A2%"=="d" GOTO END
if "%A2%"=="b" GOTO WINDOWSUPDATE

:WINDOWSUPDATE
Echo Modifying Windows Update Dual Scan registry settings
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DisableDualScan /t REG_DWORD /d 0 /f
Echo Running Command line Windows Update
powershell Import-Module PSWindowsUpdate -force
powershell Install-WindowsUpdate -AcceptAll -ignorereboot
Echo Windows Updates completed
if "%A1%"=="u" GOTO END
if "%A2%"=="w" GOTO END
if "%A2%"=="b" GOTO ADDADMIN

:ADDADMIN
ECHO Add user to Local Admin Group
set /P A4=What is the USERNAME to be added as local admin?  
powershell Add-LocalGroupMember -Group "Administrators" -Member lucid\%A4%
Powershell Get-LocalGroupMember -Group "Administrators"
Echo Please check to make sure %A4% has been successfully added to the local admin group"
Echo If not, you may have to manually add them.
Pause

:NOADMIN
Echo Sorry script cannot run without admin priviliges.
Echo Make sure to right click and "Run as Administrator"
pause
GOTO EOF

:END
Echo All done! Rebooting in 40 Seconds unless this window is closed.
Timeout 30
Shutdown -r -t 10
