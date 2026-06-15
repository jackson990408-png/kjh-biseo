@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "C_OK=%ESC%[92m"
set "C_WARN=%ESC%[93m"
set "C_ERR=%ESC%[91m"
set "C_BOLD=%ESC%[1m"
set "C_RESET=%ESC%[0m"

title KJH비서 제거

set "DEST=%USERPROFILE%\AI비서"
set "DESK=%USERPROFILE%\Desktop"

cls
echo.
echo  %C_BOLD%  ═══  KJH비서 제거  ═══%C_RESET%
echo.

if not exist "%DEST%\비서.pyw" (
    echo  %C_WARN%  KJH비서가 설치되어 있지 않습니다.%C_RESET%
    pause & exit /b 0
)

echo  제거하면 프로그램 파일이 삭제됩니다.
echo.
set /p KEEP="  대화기록·금고·프로필 등 개인 데이터도 삭제하시겠습니까? (Y=삭제 / N=보존): "

:: 프로그램 파일 제거
del /q "%DEST%\비서.pyw"       2>nul
del /q "%DEST%\CLAUDE.md"      2>nul
del /q "%DEST%\비서.ico"       2>nul
del /q "%DEST%\업데이트.bat"   2>nul
rmdir /s /q "%DEST%\업데이트"  2>nul

if /i "!KEEP!"=="Y" (
    rmdir /s /q "%DEST%" 2>nul
    echo  %C_OK%  ✔ 모든 데이터 포함 제거 완료%C_RESET%
) else (
    echo  %C_OK%  ✔ 프로그램 파일만 제거, 개인 데이터는 보존됨%C_RESET%
    echo  %C_OK%    위치: %DEST%%C_RESET%
)

:: 바탕화면 바로가기 제거
if exist "%DESK%\KJH비서.lnk" (
    del /q "%DESK%\KJH비서.lnk" 2>nul
    echo  %C_OK%  ✔ 바탕화면 바로가기 제거%C_RESET%
)

:: 레지스트리 자동시작 제거
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "KJH비서" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "AI비서" /f >nul 2>&1

echo.
echo  %C_BOLD%  제거 완료.%C_RESET%
echo.
pause
