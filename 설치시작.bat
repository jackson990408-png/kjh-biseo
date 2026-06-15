@echo off
chcp 65001 >nul
setlocal

:: 관리자 권한 확인 후 VBS로 재실행 (한글 경로 안전)
net session >nul 2>&1
if errorlevel 1 (
    echo Set sh = CreateObject("Shell.Application") > "%TEMP%\kjh_elev.vbs"
    echo sh.ShellExecute "%~f0", "", "%~dp0", "runas", 1 >> "%TEMP%\kjh_elev.vbs"
    cscript //nologo "%TEMP%\kjh_elev.vbs"
    del "%TEMP%\kjh_elev.vbs" >nul 2>&1
    exit /b
)

:: 보안 차단 해제
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%~dp0' -Recurse | Unblock-File" >nul 2>&1

:: files\비서.pyw 확인
if not exist "%~dp0files\비서.pyw" (
    echo.
    echo  [오류] files 폴더가 없거나 비어 있습니다.
    echo  ZIP 파일을 완전히 압축 해제했는지 확인하세요.
    echo.
    pause
    exit /b 1
)

:: 설치 실행
call "%~dp0KJH비서_설치.bat"
