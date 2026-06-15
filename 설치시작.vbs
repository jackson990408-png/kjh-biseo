Set fso = CreateObject("Scripting.FileSystemObject")
Set sh  = CreateObject("Shell.Application")
Set ws  = CreateObject("WScript.Shell")

dir = fso.GetParentFolderName(WScript.ScriptFullName)
bat = dir & "\KJH비서_설치.bat"

' 파일 존재 확인
If Not fso.FileExists(bat) Then
    MsgBox "오류: KJH비서_설치.bat 파일을 찾을 수 없습니다." & vbCrLf & _
           "ZIP을 완전히 압축 해제했는지 확인하세요." & vbCrLf & vbCrLf & _
           "찾는 위치: " & bat, vbCritical, "KJH비서 설치"
    WScript.Quit 1
End If

' 파일 보안 차단 해제
ws.Run "powershell -NoProfile -ExecutionPolicy Bypass -Command """ & _
    "Get-ChildItem -Path '" & dir & "' -Recurse | Unblock-File" & _
    """", 0, True

' 관리자 권한으로 설치 실행
sh.ShellExecute "cmd.exe", "/c """ & bat & """", dir, "runas", 1
