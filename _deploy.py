"""GitHub 배포 — files/biseo.pyw 와 version.json 을 PUT 업로드.
사용법:  set GH_TOKEN=ghp_xxx   &&   python _deploy.py
토큰은 환경변수로만 받고 파일에 저장하지 않는다."""
import base64, json, os, sys, urllib.request

OWNER = "jackson990408-png"
REPO = "kjh-biseo"
BRANCH = "main"
HERE = os.path.dirname(os.path.abspath(__file__))

TOKEN = os.environ.get("GH_TOKEN", "").strip()
if not TOKEN:
    print("ERROR: set GH_TOKEN first (set GH_TOKEN=ghp_xxx)")
    sys.exit(1)

FILES = [
    (os.path.join(HERE, "files", "biseo.pyw"), "files/biseo.pyw"),
    (os.path.join(HERE, "version.json"), "version.json"),
]
# 배포용 본체는 files/비서.pyw 를 files/biseo.pyw 로 보낸다
SRC_BODY = os.path.join(HERE, "files", "비서.pyw")


def api(method, path, data=None):
    url = f"https://api.github.com/repos/{OWNER}/{REPO}/{path}"
    req = urllib.request.Request(url, method=method)
    req.add_header("Authorization", f"token {TOKEN}")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("User-Agent", "kjh-deploy")
    body = json.dumps(data).encode() if data is not None else None
    if body:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, body) as r:
            return r.status, json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read().decode() or "{}")


def put_file(local_path, repo_path, message):
    with open(local_path, "rb") as f:
        content = base64.b64encode(f.read()).decode()
    # 기존 파일 sha 조회
    st, info = api("GET", f"contents/{repo_path}?ref={BRANCH}")
    sha = info.get("sha") if st == 200 else None
    payload = {"message": message, "content": content, "branch": BRANCH}
    if sha:
        payload["sha"] = sha
    st, resp = api("PUT", f"contents/{repo_path}", payload)
    ok = st in (200, 201)
    print(f"[{'OK ' if ok else 'FAIL'}] {repo_path}  (HTTP {st})")
    if not ok:
        print("   ->", resp.get("message"))
    return ok


def main():
    ok = True
    ok &= put_file(SRC_BODY, "files/biseo.pyw", "deploy KJH biseo 1.3.4")
    ok &= put_file(os.path.join(HERE, "version.json"), "version.json", "bump version 1.3.4")
    print("DONE" if ok else "SOME FAILED")


if __name__ == "__main__":
    main()
