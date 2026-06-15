@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "C_OK=%ESC%[92m"
set "C_WARN=%ESC%[93m"
set "C_ERR=%ESC%[91m"
set "C_DIM=%ESC%[90m"
set "C_BOLD=%ESC%[1m"
set "C_RESET=%ESC%[0m"

title KJH비서 업데이트

set "DEST=%USERPROFILE%\AI비서"
set "OLLAMA_PATH=%LOCALAPPDATA%\Programs\Ollama"
set "PATH=%PATH%;%OLLAMA_PATH%"

if not exist "%DEST%\로컬비서.pyw" (
    if not exist "%DEST%\비서.pyw" (
        echo %C_ERR% KJH비서가 설치되지 않았습니다. 먼저 KJH비서_설치.bat 를 실행하세요. %C_RESET%
        pause & exit /b 1
    )
)

cls
echo.
echo  %C_BOLD%  ═══  KJH비서 업데이트  ═══%C_RESET%
echo  %C_DIM%  개인 데이터(대화기록·금고·프로필)는 절대 건드리지 않습니다.%C_RESET%
echo.

:: ── 백업 ──
echo  %C_BOLD%[1/4] 개인 데이터 백업...%C_RESET%
set "DT=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "DT=%DT: =0%"
set "BK=%DEST%\백업\%DT%_업데이트전"
mkdir "%BK%" 2>nul
for %%f in (프로필.md 금고.dat 설정.json 일정.json 기억.json 대화제목.json) do (
    if exist "%DEST%\%%f" copy /y "%DEST%\%%f" "%BK%\" >nul
)
if exist "%DEST%\채팅기록" xcopy /e /i /y /q "%DEST%\채팅기록" "%BK%\채팅기록" >nul
echo  %C_OK%  ✔ 백업 완료 → %BK%%C_RESET%

:: ── 프로그램 파일 ──
echo.
echo  %C_BOLD%[2/4] 프로그램 파일 업데이트...%C_RESET%
set "SRC=%~dp0files"
if exist "%SRC%\비서.pyw" (
    copy /y "%SRC%\비서.pyw" "%DEST%\로컬비서.pyw" >nul
    echo  %C_OK%  ✔ 로컬비서.pyw 업데이트 완료%C_RESET%
) else (
    echo  %C_WARN%  △ files\비서.pyw 없음 — 프로그램 파일은 그대로%C_RESET%
)
copy /y "%~dp0KJH비서_업데이트.bat" "%DEST%\업데이트.bat" >nul 2>nul

:: ── Python 라이브러리 ──
echo.
echo  %C_BOLD%[3/4] Python 라이브러리 최신화...%C_RESET%
python -m pip install --quiet --upgrade ^
    pywebview cryptography ezdxf openpyxl python-docx python-pptx ^
    pypdf Pillow pywin32 pyautogui faster-whisper sounddevice numpy pystray olefile
if errorlevel 1 (echo  %C_WARN%  △ 일부 업그레이드 실패 (큰 문제 아님)%C_RESET%) else (echo  %C_OK%  ✔ 라이브러리 업데이트 완료%C_RESET%)

:: ── AI 모델 ──
echo.
echo  %C_BOLD%[4/4] AI 모델 최신화...%C_RESET%
where ollama >nul 2>&1
if errorlevel 1 (
    echo  %C_WARN%  △ Ollama 없음 — 건너뜀%C_RESET%
    goto :DONE
)
start /b "" ollama serve >nul 2>&1
timeout /t 3 /nobreak >nul
for /f "tokens=1" %%m in ('ollama list 2^>nul ^| findstr /v "^NAME"') do (
    echo  %C_DIM%  업데이트 중: %%m%C_RESET%
    ollama pull %%m
)
echo  %C_OK%  ✔ 모델 최신화 완료%C_RESET%

:DONE
echo.
echo  %C_BOLD%  ═══  업데이트 완료!  ═══%C_RESET%
echo  %C_DIM%  복원이 필요하면: %BK%%C_RESET%
echo.
set /p RUN="  지금 바로 KJH비서를 실행하시겠습니까? (Y/N): "
if /i "!RUN!"=="Y" start "" "%DEST%\비서실행.bat"
echo.
pause
