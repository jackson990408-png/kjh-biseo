# GitHub 업데이트 서버 설정 방법

자동 업데이트가 동작하려면 GitHub에 버전 정보를 올려야 합니다.
한 번만 설정하면 됩니다.

---

## 1단계 — GitHub 계정 만들기

https://github.com 에서 무료 계정을 만드세요.

---

## 2단계 — 저장소(Repository) 만들기

1. GitHub 로그인 → 오른쪽 위 [+] → [New repository]
2. Repository name: `kjh-biseo` (또는 원하는 이름)
3. **Public** 선택 (Private이면 다운로드 불가)
4. [Create repository] 클릭

---

## 3단계 — 배포 폴더를 GitHub에 올리기

**방법 A — GitHub Desktop 사용 (가장 쉬움)**
1. https://desktop.github.com 에서 GitHub Desktop 다운로드
2. 설치 후 로그인
3. [File] → [Add Local Repository] → 이 배포 폴더 선택
4. [Publish Repository]

**방법 B — 웹 업로드**
1. GitHub 저장소 페이지에서 [Add file] → [Upload files]
2. `files/비서.pyw` 와 `version.json` 을 끌어다 놓기
3. [Commit changes] 클릭

---

## 4단계 — URL 확인 및 비서.pyw에 입력

GitHub에 올리면 아래 형태의 URL이 생깁니다:

```
https://raw.githubusercontent.com/내아이디/kjh-biseo/main/version.json
https://raw.githubusercontent.com/내아이디/kjh-biseo/main/files/비서.pyw
```

`내아이디`를 실제 GitHub 아이디로 바꾸세요.

**비서.pyw (또는 로컬비서.pyw) 파일을 열고:**
```python
UPDATE_JSON_URL = ""   # ← 이 줄을 찾아서
```
아래처럼 수정:
```python
UPDATE_JSON_URL = "https://raw.githubusercontent.com/내아이디/kjh-biseo/main/version.json"
```

**version.json의 download_url도 같이 수정:**
```json
"download_url": "https://raw.githubusercontent.com/내아이디/kjh-biseo/main/files/비서.pyw"
```

---

## 이후 업데이트 배포 방법

새 버전을 만들 때마다:
1. **`개발자_배포준비.bat`** 실행 → 버전 번호 입력 → 자동 준비
2. GitHub Desktop에서 **Commit + Push**

→ 그러면 앱을 실행 중인 사용자 모두에게 자동 업데이트 알림이 뜹니다!
