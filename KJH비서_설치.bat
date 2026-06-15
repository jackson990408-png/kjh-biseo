@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "C_TITLE=%ESC%[96m"
set "C_OK=%ESC%[92m"
set "C_WARN=%ESC%[93m"
set "C_ERR=%ESC%[91m"
set "C_DIM=%ESC%[90m"
set "C_RESET=%ESC%[0m"
set "C_BOLD=%ESC%[1m"

title KJH비서 설치

:: ── 인터넷 보안 차단 자동 해제 (Mark of the Web 제거) ──
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Get-ChildItem -Path '%~dp0' -Recurse -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue" >nul 2>&1

cls
echo.
echo  %C_TITLE%%C_BOLD%  ╔══════════════════════════════════════════╗  %C_RESET%
echo  %C_TITLE%%C_BOLD%  ║       ✱  KJH비서  설치 프로그램         ║  %C_RESET%
echo  %C_TITLE%%C_BOLD%  ╚══════════════════════════════════════════╝  %C_RESET%
echo.
echo  %C_DIM%이 컴퓨터에 KJH비서를 설치합니다.%C_RESET%
echo  %C_DIM%개인 데이터(대화기록·금고·프로필)는 포함되지 않습니다.%C_RESET%
echo  %C_DIM%인터넷은 설치할 때만 사용 — 이후 대화는 내 PC에서만 처리됩니다.%C_RESET%
echo.
echo  %C_WARN%  설치 시간: 약 10분~30분 (인터넷 속도·GPU에 따라 다름)%C_RESET%
echo  %C_WARN%  AI 모델(1~5GB)을 다운로드하므로 와이파이 환경을 권장합니다.%C_RESET%
echo.
echo  설치를 시작하려면 아무 키나 누르세요. (중단: Ctrl+C)
pause >nul
echo.

set "DEST=%USERPROFILE%\AI비서"
set "TOTAL_STEPS=7"
set "STEP=0"
set "ERRORS=0"
set "PYTHON_CMD=python"

:: ─────────────────────────────────────────────────────────────
:: [STEP 1] 폴더 생성
:: ─────────────────────────────────────────────────────────────
set /a STEP+=1
echo  %C_BOLD%[%STEP%/%TOTAL_STEPS%] 폴더 생성...%C_RESET%
mkdir "%DEST%"            2>nul
mkdir "%DEST%\받은파일"    2>nul
mkdir "%DEST%\결과물"      2>nul
mkdir "%DEST%\채팅기록"    2>nul
mkdir "%DEST%\백업"        2>nul
mkdir "%DEST%\업데이트"    2>nul
echo  %C_OK%  ✔ %DEST%%C_RESET%

:: ─────────────────────────────────────────────────────────────
:: [STEP 2] 프로그램 파일 복사
:: ─────────────────────────────────────────────────────────────
set /a STEP+=1
echo.
echo  %C_BOLD%[%STEP%/%TOTAL_STEPS%] 프로그램 파일 복사...%C_RESET%

set "FILE_ERR=0"
copy /y "%~dp0files\비서.pyw"  "%DEST%\로컬비서.pyw"  >nul 2>&1 || set "FILE_ERR=1"
copy /y "%~dp0files\CLAUDE.md" "%DEST%\"               >nul 2>&1
copy /y "%~dp0files\비서.ico"  "%DEST%\"               >nul 2>&1
copy /y "%~dp0KJH비서_업데이트.bat" "%DEST%\업데이트.bat" >nul 2>&1

if "!FILE_ERR!"=="1" (
    echo  %C_ERR%  ✗ 비서.pyw 복사 실패 — files\ 폴더가 없거나 손상됐습니다.%C_RESET%
    set /a ERRORS+=1
) else (
    echo  %C_OK%  ✔ 파일 복사 완료%C_RESET%
)

:: ─────────────────────────────────────────────────────────────
:: [STEP 3] Python 확인 / 설치
:: ─────────────────────────────────────────────────────────────
set /a STEP+=1
echo.
echo  %C_BOLD%[%STEP%/%TOTAL_STEPS%] Python 확인...%C_RESET%

call :FindPython
if "!PYTHON_CMD!"=="" (
    echo  %C_WARN%  Python이 없습니다. 자동 설치를 시도합니다...%C_RESET%
    call :InstallPython
    call :FindPython
)

if "!PYTHON_CMD!"=="" (
    echo  %C_ERR%  ✗ Python을 찾을 수 없습니다.%C_RESET%
    echo  %C_ERR%    https://www.python.org/downloads/ 에서 Python 3.11 이상을 설치하고 다시 실행하세요.%C_RESET%
    set /a ERRORS+=1
    goto :SKIP_PIP
) else (
    for /f "tokens=*" %%v in ('!PYTHON_CMD! --version 2^>^&1') do echo  %C_OK%  ✔ %%v%C_RESET%
)

:: ─────────────────────────────────────────────────────────────
:: [STEP 4] Python 라이브러리 설치
:: ─────────────────────────────────────────────────────────────
set /a STEP+=1
echo.
echo  %C_BOLD%[%STEP%/%TOTAL_STEPS%] Python 라이브러리 설치...%C_RESET%
echo  %C_DIM%  (첫 설치 시 2~5분 소요될 수 있습니다)%C_RESET%

:: pip 업그레이드
!PYTHON_CMD! -m pip install --quiet --upgrade pip 2>nul

:: 핵심 패키지 (필수)
echo  %C_DIM%  핵심 패키지 설치 중...%C_RESET%
!PYTHON_CMD! -m pip install --quiet ^
    pywebview cryptography openpyxl python-docx python-pptx ^
    pypdf Pillow pywin32 pyautogui comtypes olefile
if errorlevel 1 (
    echo  %C_ERR%  ✗ 핵심 패키지 설치 실패%C_RESET%
    set /a ERRORS+=1
) else (
    echo  %C_OK%  ✔ 핵심 패키지 완료%C_RESET%
)

:: 선택 패키지 (없어도 기본 기능 작동)
echo  %C_DIM%  확장 패키지 설치 중 (CAD·그래프·음성)...%C_RESET%
!PYTHON_CMD! -m pip install --quiet ezdxf matplotlib numpy sounddevice 2>nul
if errorlevel 1 echo  %C_WARN%  △ 일부 확장 패키지 실패 (기본 기능은 정상)%C_RESET%

:: 음성인식 (CUDA 필요 — 실패해도 무시)
!PYTHON_CMD! -m pip install --quiet faster-whisper 2>nul
if errorlevel 1 (
    echo  %C_WARN%  △ faster-whisper 설치 실패 (음성인식 제외, 나머지 정상)%C_RESET%
) else (
    echo  %C_OK%  ✔ 확장 패키지 완료%C_RESET%
)

:SKIP_PIP

:: ─────────────────────────────────────────────────────────────
:: [STEP 5] Ollama (로컬 AI 엔진) 설치
:: ─────────────────────────────────────────────────────────────
set /a STEP+=1
echo.
echo  %C_BOLD%[%STEP%/%TOTAL_STEPS%] Ollama (로컬 AI 엔진) 설치...%C_RESET%

:: PATH에 Ollama 경로 추가 (winget 설치 후 바로 반영)
set "OLLAMA_PATH=%LOCALAPPDATA%\Programs\Ollama"
set "PATH=%PATH%;%OLLAMA_PATH%"

where ollama >nul 2>&1
if errorlevel 1 (
    echo  %C_WARN%  Ollama를 설치합니다 (약 300MB)...%C_RESET%
    call :InstallOllama
    :: 설치 후 PATH 재탐색
    set "PATH=%PATH%;%LOCALAPPDATA%\Programs\Ollama"
    where ollama >nul 2>&1
    if errorlevel 1 (
        echo  %C_ERR%  ✗ Ollama 설치 실패.%C_RESET%
        echo  %C_ERR%    https://ollama.com 에서 직접 설치 후 다시 실행하세요.%C_RESET%
        set /a ERRORS+=1
        goto :SKIP_MODEL
    )
) else (
    for /f "tokens=*" %%v in ('ollama --version 2^>^&1') do echo  %C_OK%  ✔ Ollama %%v 이미 설치됨%C_RESET%
)

:: ─────────────────────────────────────────────────────────────
:: [STEP 6] GPU 감지 → AI 모델 자동 선택·다운로드
:: ─────────────────────────────────────────────────────────────
set /a STEP+=1
echo.
echo  %C_BOLD%[%STEP%/%TOTAL_STEPS%] AI 모델 다운로드...%C_RESET%

set "VRAM=0"
set "GPU_NAME=CPU 전용"
where nvidia-smi >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=1 delims=." %%v in ('nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2^>nul') do set "VRAM=%%v"
    for /f "tokens=*" %%g in ('nvidia-smi --query-gpu=name --format=csv,noheader 2^>nul') do set "GPU_NAME=%%g"
)

echo  %C_DIM%  GPU: !GPU_NAME!  /  VRAM: !VRAM! MB%C_RESET%

:: VRAM에 따라 모델 선택
if !VRAM! GEQ 10000 (
    set "TEXT_MODEL=exaone3.5:7.8b"
    set "VISION_MODEL=gemma3:12b"
    echo  %C_OK%  ✔ 고사양 모드 — exaone3.5:7.8b + gemma3:12b%C_RESET%
) else if !VRAM! GEQ 5500 (
    set "TEXT_MODEL=qwen2.5:7b"
    set "VISION_MODEL=gemma3:4b"
    echo  %C_OK%  ✔ 표준 모드 — qwen2.5:7b + gemma3:4b%C_RESET%
) else if !VRAM! GEQ 3000 (
    set "TEXT_MODEL=exaone3.5:2.4b"
    set "VISION_MODEL=gemma3:4b"
    echo  %C_WARN%  △ 경량 모드 — exaone3.5:2.4b%C_RESET%
) else (
    set "TEXT_MODEL=gemma3:4b"
    set "VISION_MODEL=gemma3:4b"
    echo  %C_WARN%  △ CPU 모드 — gemma3:4b (응답이 다소 느립니다)%C_RESET%
)
set "EMBED_MODEL=bge-m3"

:: Ollama 서버 시작
echo  %C_DIM%  Ollama 서버 시작 중...%C_RESET%
start /b "" ollama serve >nul 2>&1
timeout /t 5 /nobreak >nul

:: 모델 다운로드 (이미 있으면 바로 완료)
echo  %C_DIM%  [1/3] 텍스트 모델 다운로드: !TEXT_MODEL! (1~5GB, 가장 오래 걸립니다)%C_RESET%
ollama pull !TEXT_MODEL!
if errorlevel 1 (echo  %C_ERR%  ✗ 텍스트 모델 다운로드 실패%C_RESET% & set /a ERRORS+=1) else (echo  %C_OK%  ✔ 텍스트 모델 완료%C_RESET%)

if "!TEXT_MODEL!" neq "!VISION_MODEL!" (
    echo  %C_DIM%  [2/3] 이미지 분석 모델: !VISION_MODEL!%C_RESET%
    ollama pull !VISION_MODEL!
    if errorlevel 1 echo  %C_WARN%  △ 이미지 모델 실패 (텍스트 기능은 정상)%C_RESET%
) else (
    echo  %C_DIM%  [2/3] 이미지 모델: 텍스트 모델과 동일 — 생략%C_RESET%
)

echo  %C_DIM%  [3/3] 의미검색 모델: !EMBED_MODEL! (약 1.2GB)%C_RESET%
ollama pull !EMBED_MODEL!
if errorlevel 1 echo  %C_WARN%  △ 검색 모델 실패 (기억 검색 기능 제한)%C_RESET%

echo  %C_OK%  ✔ AI 모델 준비 완료%C_RESET%

:SKIP_MODEL

:: ─────────────────────────────────────────────────────────────
:: [STEP 7] 바탕화면 바로가기 + 시작 스크립트 생성
:: ─────────────────────────────────────────────────────────────
set /a STEP+=1
echo.
echo  %C_BOLD%[%STEP%/%TOTAL_STEPS%] 바로가기·실행 스크립트 생성...%C_RESET%

:: 실행 스크립트 생성 (Ollama 자동 시작 포함)
(
echo @echo off
echo chcp 65001 ^>nul
echo start /b "" ollama serve ^>nul 2^>^&1
echo timeout /t 2 /nobreak ^>nul
echo start "" pythonw.exe "%DEST%\로컬비서.pyw"
) > "%DEST%\비서실행.bat"
echo  %C_OK%  ✔ 비서실행.bat 생성 완료%C_RESET%

:: 바탕화면 바로가기 (아이콘 + 단축키 포함)
set "SHORTCUT_ERR=0"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$dest='%DEST%';" ^
  "$desk=[Environment]::GetFolderPath('Desktop');" ^
  "$ws=New-Object -ComObject WScript.Shell;" ^
  "$bat=Join-Path $dest 'biseo-run-helper.vbs';" ^
  "@'" ^
  "Set sh = CreateObject(\"\"WScript.Shell\"\")" ^
  "sh.Run Chr(34) & \"\"%DEST%\비서실행.bat\"\" & Chr(34), 0" ^
  "'@ | Out-File -FilePath $bat -Encoding ascii;" ^
  "$sc=$ws.CreateShortcut((Join-Path $desk 'KJH비서.lnk'));" ^
  "$sc.TargetPath=$bat;" ^
  "$sc.WorkingDirectory=$dest;" ^
  "$ico=Join-Path $dest '비서.ico';" ^
  "if(Test-Path $ico){$sc.IconLocation=$ico+',0'};" ^
  "$sc.Hotkey='CTRL+ALT+K';" ^
  "$sc.Description='KJH비서 — 로컬 AI 비서 (Ctrl+Alt+K)';" ^
  "$sc.Save();" ^
  "Write-Output 'ok'" 2>nul | findstr "ok" >nul

if errorlevel 1 (
    :: VBS 방식 실패 시 단순 pythonw 방식으로 재시도
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "$dest='%DEST%';" ^
      "$desk=[Environment]::GetFolderPath('Desktop');" ^
      "$ws=New-Object -ComObject WScript.Shell;" ^
      "$py=(Get-Command pythonw.exe -ErrorAction SilentlyContinue).Source;" ^
      "if(-not $py){$py='pythonw.exe'};" ^
      "$sc=$ws.CreateShortcut((Join-Path $desk 'KJH비서.lnk'));" ^
      "$sc.TargetPath=$py;" ^
      "$sc.Arguments='\"'+(Join-Path $dest '로컬비서.pyw')+'\"';" ^
      "$sc.WorkingDirectory=$dest;" ^
      "$ico=Join-Path $dest '비서.ico';" ^
      "if(Test-Path $ico){$sc.IconLocation=$ico+',0'};" ^
      "$sc.Hotkey='CTRL+ALT+K';" ^
      "$sc.Description='KJH비서';" ^
      "$sc.Save()" 2>nul
    echo  %C_WARN%  △ 바로가기 생성됨 (Ollama 자동시작 없는 단순 버전)%C_RESET%
) else (
    echo  %C_OK%  ✔ 바탕화면 "KJH비서" 아이콘 생성 완료 (단축키: Ctrl+Alt+K)%C_RESET%
)

:: ─────────────────────────────────────────────────────────────
:: 완료 화면
:: ─────────────────────────────────────────────────────────────
echo.
if !ERRORS!==0 (
    echo  %C_TITLE%%C_BOLD%  ╔══════════════════════════════════════════╗  %C_RESET%
    echo  %C_TITLE%%C_BOLD%  ║       ✔  KJH비서 설치 완료!             ║  %C_RESET%
    echo  %C_TITLE%%C_BOLD%  ╚══════════════════════════════════════════╝  %C_RESET%
) else (
    echo  %C_WARN%%C_BOLD%  ╔══════════════════════════════════════════╗  %C_RESET%
    echo  %C_WARN%%C_BOLD%  ║  △ 설치 완료 (오류 !ERRORS!건 — 위 내용 확인)      ║  %C_RESET%
    echo  %C_WARN%%C_BOLD%  ╚══════════════════════════════════════════╝  %C_RESET%
)
echo.
echo  %C_BOLD%  시작 방법%C_RESET%
echo    바탕화면의 "KJH비서" 아이콘을 더블클릭  (또는 Ctrl+Alt+K)
echo.
echo  %C_BOLD%  설치 위치%C_RESET%    %DEST%
echo  %C_BOLD%  나중에 업데이트%C_RESET%  앱 실행 후 ☰ → 🔄 업데이트 확인
echo.
echo  %C_DIM%  * 처음 실행 시 AI 모델 로딩에 약 10~30초 걸립니다.%C_RESET%
echo  %C_DIM%  * 대화 내용은 이 PC 안에서만 처리됩니다.%C_RESET%
echo.
set /p RUN="  지금 바로 KJH비서를 실행하시겠습니까? (Y/N): "
if /i "!RUN!"=="Y" (
    start "" "%DEST%\비서실행.bat"
    echo  %C_OK%  KJH비서를 실행했습니다!%C_RESET%
)
echo.
pause
exit /b 0


:: ════════════════════════════════════════════
:: 서브루틴
:: ════════════════════════════════════════════

:FindPython
:: Python 실행 경로를 찾아 PYTHON_CMD 변수에 저장
set "PYTHON_CMD="
for %%c in (python python3 py) do (
    if "!PYTHON_CMD!"=="" (
        %%c --version >nul 2>&1 && set "PYTHON_CMD=%%c"
    )
)
:: winget 설치 후 PATH가 갱신 안 됐을 경우 직접 탐색
if "!PYTHON_CMD!"=="" (
    for %%d in (
        "%LOCALAPPDATA%\Programs\Python\Python313"
        "%LOCALAPPDATA%\Programs\Python\Python312"
        "%LOCALAPPDATA%\Programs\Python\Python311"
        "%LOCALAPPDATA%\Programs\Python\Python310"
        "C:\Python313" "C:\Python312" "C:\Python311" "C:\Python310"
        "%ProgramFiles%\Python313" "%ProgramFiles%\Python312"
    ) do (
        if "!PYTHON_CMD!"=="" if exist "%%~d\python.exe" set "PYTHON_CMD=%%~d\python.exe"
    )
)
goto :eof

:InstallPython
:: winget으로 설치 시도 → 실패 시 직접 다운로드
where winget >nul 2>&1
if not errorlevel 1 (
    echo  %C_DIM%  winget으로 Python 3.13 설치 중...%C_RESET%
    winget install --id Python.Python.3.13 --silent --accept-package-agreements --accept-source-agreements
    if not errorlevel 1 (
        :: winget 설치 후 PATH 갱신 (레지스트리에서 읽기)
        for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "UPATH=%%b"
        if not "!UPATH!"=="" set "PATH=!PATH!;!UPATH!"
        set "PATH=!PATH!;%LOCALAPPDATA%\Programs\Python\Python313;%LOCALAPPDATA%\Programs\Python\Python313\Scripts"
        goto :eof
    )
)
:: winget 없거나 실패 → 직접 다운로드 (PowerShell)
echo  %C_DIM%  winget 없음. Python 인스톨러 직접 다운로드 중...%C_RESET%
set "PY_URL=https://www.python.org/ftp/python/3.13.0/python-3.13.0-amd64.exe"
set "PY_INST=%TEMP%\python_installer.exe"
powershell -NoProfile -Command "try{[Net.ServicePointManager]::SecurityProtocol='Tls12';(New-Object Net.WebClient).DownloadFile('%PY_URL%','%PY_INST%');Write-Output 'ok'}catch{Write-Output 'fail'}" | findstr "ok" >nul
if errorlevel 1 (
    echo  %C_ERR%  ✗ Python 다운로드 실패. 인터넷 연결을 확인하세요.%C_RESET%
    goto :eof
)
echo  %C_DIM%  Python 설치 중 (자동 설치, 약 1분)...%C_RESET%
"%PY_INST%" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 Include_launcher=1
timeout /t 3 /nobreak >nul
del "%PY_INST%" 2>nul
set "PATH=%PATH%;%LOCALAPPDATA%\Programs\Python\Python313;%LOCALAPPDATA%\Programs\Python\Python313\Scripts"
goto :eof

:InstallOllama
:: winget으로 설치 시도 → 실패 시 직접 다운로드
where winget >nul 2>&1
if not errorlevel 1 (
    echo  %C_DIM%  winget으로 Ollama 설치 중...%C_RESET%
    winget install --id Ollama.Ollama --silent --accept-package-agreements --accept-source-agreements
    if not errorlevel 1 (
        set "PATH=%PATH%;%LOCALAPPDATA%\Programs\Ollama"
        timeout /t 5 /nobreak >nul
        goto :eof
    )
)
:: winget 없거나 실패 → 직접 다운로드
echo  %C_DIM%  winget 없음. Ollama 인스톨러 직접 다운로드 중 (약 300MB)...%C_RESET%
set "OL_URL=https://ollama.com/download/OllamaSetup.exe"
set "OL_INST=%TEMP%\OllamaSetup.exe"
powershell -NoProfile -Command "try{[Net.ServicePointManager]::SecurityProtocol='Tls12';(New-Object Net.WebClient).DownloadFile('%OL_URL%','%OL_INST%');Write-Output 'ok'}catch{Write-Output 'fail'}" | findstr "ok" >nul
if errorlevel 1 (
    echo  %C_ERR%  ✗ Ollama 다운로드 실패. 인터넷 연결을 확인하세요.%C_RESET%
    goto :eof
)
echo  %C_DIM%  Ollama 설치 중...%C_RESET%
"%OL_INST%" /S
timeout /t 8 /nobreak >nul
del "%OL_INST%" 2>nul
set "PATH=%PATH%;%LOCALAPPDATA%\Programs\Ollama"
goto :eof
