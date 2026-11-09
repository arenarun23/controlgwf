#!/usr/bin/env bash
# 사용법: check_deploy.sh <배포주소 예: https://controlgwf.vercel.app> <클라이언트ID> [추가 리디렉션 URI ...]
# 1) 배포된 번들에 클라이언트 ID가 들어 있는지  2) 구글이 리디렉션 URI를 인식하는지 확인한다. 읽기 전용.
set -u
SITE="${1:?배포 주소}"; ID="${2:?클라이언트 ID}"; shift 2
SITE="${SITE%/}"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

echo "== 1. 배포 번들에 클라이언트 ID가 들어 있나"
curl -sS --max-time 20 "$SITE/" -o "$TMP/idx.html" || { echo "접속 실패"; exit 1; }
JS="$(grep -o 'assets/index-[A-Za-z0-9_-]*\.js' "$TMP/idx.html" | head -1)"
echo "번들: ${JS:-없음}"
if [ -n "$JS" ]; then
  curl -sS --max-time 20 "$SITE/$JS" -o "$TMP/b.js"
  if grep -q "${ID%%-*}" "$TMP/b.js"; then echo "OK: 클라이언트 ID가 번들에 있음"
  else echo "실패: 번들에 ID 없음 → Vercel 환경변수 이름/환경(Production)/재배포(빌드 캐시 끄기) 확인"; fi
fi

echo; echo "== 2. 구글이 리디렉션 URI를 인식하나"
for U in "$SITE/" "$@"; do
  curl -sS -L --max-time 20 -G "https://accounts.google.com/o/oauth2/v2/auth" \
    --data-urlencode "client_id=$ID" --data-urlencode "redirect_uri=$U" \
    --data-urlencode "response_type=token" \
    --data-urlencode "scope=https://www.googleapis.com/auth/userinfo.email" -o "$TMP/o.html"
  R="$(grep -o -i -E 'redirect_uri_mismatch|invalid_client|deleted_client|org_internal' "$TMP/o.html" | sort -u | head -1)"
  if [ -z "$R" ]; then echo "OK   $U"; else echo "실패 $U  ($R)"; fi
done
