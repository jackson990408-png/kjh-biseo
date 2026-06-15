@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ══════════════════════════════════════════════════════════════
::  KJH비서 설치 — 더블클릭만 하면 끝!
::  관리자 권한 자동 요청 + 보안차단 자동 해제 포함
:: ══════════════════════════════════════════════════════════════

:: ── [자동] 관리자 권한 없으면 스스로 재실행 ──
net session >nul 2>&1
if errorlevel 1 (
    powershell -NoProfile -Command ^
      "Start-Process -FilePath '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b
)

:: ── [자동] 이 폴더 전체 보안차단 해제 (인터넷에서 받은 파일 차단 제거) ──
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Get-ChildItem -Path '%~dp0' -Recurse -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue" >nul 2>&1

:: ── 실제 설치 실행 ──
call "%~dp0KJH비서_설치.bat"
