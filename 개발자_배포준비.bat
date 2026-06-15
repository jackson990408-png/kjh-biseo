@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ═══════════════════════════════════════════════════════════
:: KJH비서 개발자 배포 도구
:: 새 버전 업데이트 파일을 배포 폴더에 자동으로 준비해 줍니다.
:: ═══════════════════════════════════════════════════════════

title KJH비서 배포 준비 도구

:: ▶ 설정: 개발 원본 파일 위치
set "SRC_PYW=C:\Users\jacsk\Desktop\AI비서만들기\클로드2\클로드\개인컴퓨터비서\AI비서\AI비서\로컬비서.pyw"
set "DEPLOY_DIR=%~dp0"

cls
echo.
echo  ╔══════════════════════════════════════╗
echo  ║  KJH비서 개발자 배포 준비 도구       ║
echo  ╚══════════════════════════════════════╝
echo.

:: 현재 버전 읽기
for /f "tokens=2 delims=:, " %%v in ('findstr "version" "%DEPLOY_DIR%version.json" 2^>nul ^| findstr /v "download"') do (
    set "CUR_VER=%%v"
    set "CUR_VER=!CUR_VER:"=!"
    goto :GOT_VER
)
:GOT_VER
echo  현재 배포 버전: %CUR_VER%
echo.

:: 새 버전 번호 입력
echo  새 버전 번호를 입력하세요.
echo  형식: KJH비서_1.0.0  (숫자만 올리면 됩니다, 예: KJH비서_1.1.0)
echo.
set /p NEW_VER="  새 버전: "
if "!NEW_VER!"=="" (echo 버전 입력 없음. 종료. & pause & exit /b 1)

:: 업데이트 내용 입력
echo.
set /p CHANGELOG="  변경 내용 한 줄 요약 (예: 일정 알림 개선 및 버그 수정): "

:: 원본 파일에서 VERSION 상수 업데이트
echo.
echo  [1/3] 원본 파일에서 버전 상수 업데이트...
python -c "
import re, sys
path = sys.argv[1]
ver  = sys.argv[2]
with open(path, encoding='utf-8') as f:
    content = f.read()
content = re.sub(r'VERSION\s*=\s*\"KJH비서_[\d.]+\"', f'VERSION = \"{ver}\"', content)
with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('OK')
" "%SRC_PYW%" "!NEW_VER!"
if errorlevel 1 (echo  ✗ 버전 상수 업데이트 실패 & pause & exit /b 1)
echo  ✔ 비서.pyw 버전 상수: !NEW_VER!

:: 배포 폴더에 파일 복사
echo.
echo  [2/3] 배포 폴더에 파일 복사...
copy /y "%SRC_PYW%" "%DEPLOY_DIR%files\비서.pyw" >nul
echo  ✔ files\비서.pyw 복사 완료

:: version.json 업데이트
echo.
echo  [3/3] version.json 업데이트...
python -c "
import json, sys
path, ver, cl = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    with open(path, encoding='utf-8') as f:
        data = json.load(f)
except:
    data = {}
data['version'] = ver
data['changelog'] = cl
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
print('OK')
" "%DEPLOY_DIR%version.json" "!NEW_VER!" "!CHANGELOG!"
echo  ✔ version.json 업데이트 완료

:: 결과 출력
echo.
echo  ═══════════════════════════════════════════════════
echo  ✔ 배포 준비 완료!
echo  ═══════════════════════════════════════════════════
echo.
echo  이제 GitHub에 다음 파일들을 올리세요:
echo.
echo    1. files\비서.pyw
echo    2. version.json
echo.
echo  GitHub에 올리는 방법:
echo    A. GitHub Desktop 앱 사용 (가장 쉬움)
echo       → 이 폴더를 저장소로 열고 Commit + Push
echo    B. 명령줄: git add files\비서.pyw version.json
echo               git commit -m "버전 !NEW_VER! 배포"
echo               git push
echo.
echo  GitHub에 올리면 사용자들이 앱을 열었을 때
echo  자동으로 업데이트 알림을 받게 됩니다.
echo.
pause
