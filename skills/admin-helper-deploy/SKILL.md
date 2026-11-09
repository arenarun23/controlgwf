---
name: admin-helper-deploy
description: 오픈소스 웹앱 Admin Helper(구글 워크스페이스 관리자 도우미, Kang-T/admin-helper)를 복사해 자기 GitHub·Vercel·구글 클라우드(OAuth)로 배포하고 로그인까지 되게 만드는 절차와 막힘 해결법. "admin-helper 적용", "관리자 도우미 배포", "OAuth 클라이언트 ID 넣었는데 로그인 버튼이 안 나와요", "설정이 필요합니다 SETUP_OAUTH.md", "redirect_uri_mismatch", "Vercel 환경변수 VITE_", "내부 사용자만 허용인데 승인 화면", "어느 계정으로 로그인해야 하나" 같은 말이 나오거나, 정적 React/Vite 앱을 Vercel에 올리고 구글 로그인을 붙이는 작업이면 명시적으로 요청하지 않아도 이 스킬을 사용한다.
---

# Admin Helper 복사·배포·로그인 연결

서버 없는 정적 웹앱(React 19 + Vite)이다. 브라우저가 관리자 본인의 구글 OAuth 토큰으로 Admin SDK 등을 직접 호출한다.
그래서 배포에 필요한 설정은 **OAuth 클라이언트 ID 하나**뿐이고, 막히는 곳은 거의 이 값이 앱에 들어가는 경로다.

## 전체 순서

1. **복사**: 원본을 `--depth 1`로 받고 `.git`·`node_modules`·`dist`를 빼고 새 폴더로 옮긴 뒤 새 git 저장소로 커밋한다. 원본 기록과 연결하지 않는다. MIT라 허용되며 `LICENSE`는 그대로 둔다.
2. **내 GitHub에 올리기**: 사용자가 빈 저장소를 만들어 주면 push 권한으로 연결해 `main`에 올린다. 저장소 이름만 들었다면 `list_repos`로 소유자를 찾는다.
3. **Vercel 연결**: 저장소를 Import하면 Vite로 자동 인식된다. Build `npm run build`, Output `dist`. 배포 주소(`https://<이름>.vercel.app`)를 확인한다.
4. **OAuth 클라이언트 만들기**(사용자가 직접): 단계는 저장소의 `SETUP_OAUTH.md`. 여기서 기억할 것은 아래 "구글 쪽 규칙".
5. **환경변수 + 재배포**(사용자가 직접): 아래 "Vercel 쪽 규칙".
6. **코드 정리**: 원본 운영자 흔적을 걷어낸다(아래 "정리할 것").
7. **확인**: `scripts/check_deploy.sh <배포주소> <클라이언트ID> [추가 URI]`. 번들에 ID가 있는지, 구글이 리디렉션 URI를 인식하는지 읽기 전용으로 점검한다.

사용자에게는 클라우드·Vercel 화면 조작을 한 번에 한 단계씩, 화면에 보이는 글자 그대로 안내한다. 사용자가 비개발자일 수 있다.

## 구글 쪽 규칙

- **클라이언트 ID는 공개돼도 되는 값**이다. 채팅·코드에 있어도 되고, 클라이언트 보안 비밀번호는 쓰지 않으니 받지 않는다.
- **리디렉션 URI는 끝의 `/`까지 정확히** 등록한다(`https://주소/`). **JavaScript 원본은 `/` 없이**(`https://주소`). 둘을 헷갈리면 각각 `redirect_uri_mismatch`, `origin_mismatch`가 난다.
- 로컬 개발용 `http://localhost:5173`(원본)과 `http://localhost:5173/`(리디렉션)도 넣는다. 안 넣으면 Vercel은 되는데 로컬만 mismatch가 나는 것이 정상적으로 보이는 증상이다.
- **"내부" 동의 화면은 구글 심사가 필요 없다**("인증이 필요하지 않습니다"가 정상). 대신 그 클라우드 프로젝트를 소유한 조직(도메인)의 계정만 로그인된다. 다른 도메인을 관리해야 하면 **외부 + 테스트 모드**로 바꾸고 해당 관리자 계정을 테스트 사용자(100명까지)로 추가한다.
- **로그인 계정은 관리 대상 워크스페이스의 관리자 권한**이 있어야 한다. 일반 계정은 로그인은 돼도 작업이 거부된다.
- API 4개를 **그 프로젝트에서** 켠다: Admin SDK, Enterprise License Manager, Google Classroom, Cloud Identity. 안 켜면 `accessNotConfigured`.
- 프로젝트가 여러 개면 혼동하기 쉽다. 클라이언트 ID 앞 숫자(`15884462982-…`)가 프로젝트 번호이니 콘솔의 프로젝트 번호와 맞춰 본다.

## Vercel 쪽 규칙

- 새 화면에는 Settings 왼쪽 메뉴에 "Environment Variables"가 **없다**. **Settings → Environments → Production**을 눌러 들어간 화면 안에 있다. 주소 `…/settings/environment-variables`로도 갈 수 있다.
- 이름은 정확히 `VITE_GOOGLE_CLIENT_ID`. `VITE_` 접두사가 없으면 Vite가 앱에 넣지 않는다.
- **Production 환경**에 들어 있어야 한다.
- 이 값은 **빌드할 때 번들에 박힌다**. 저장만 하고 재배포하지 않으면 반영되지 않는다. 변수 저장 시각보다 이전에 빌드된 배포가 계속 서비스되는 것이 가장 흔한 함정이다. Deployments → 가장 위 배포 ⋯ → Redeploy → **Use existing Build Cache 체크 해제**.
- 반영 확인은 눈으로 하지 말고 스크립트로 한다. 번들 파일명이 바뀌고 ID가 들어 있으면 성공이다. 화면에서는 "설정이 필요합니다" 문구 대신 로그인 버튼이 보인다(브라우저 캐시면 Ctrl+Shift+R).

## 정리할 것 (원본 흔적)

- **「사용 신청하기」 링크**(`src/App.tsx`의 `APPLY_FORM_URL`): 원본 운영자의 구글 설문이다. 남기면 우리 사용자의 이메일이 원본 운영자에게 간다. 상수와 문단을 지운다. 이 문구가 "구글 승인을 받아야 한다"는 뜻으로 오해되기 쉬우니 사용자에게 구글 심사와 무관하다고 설명한다.
- 소스 코드 링크를 우리 저장소로 바꾼다.
- 남은 항목(사용자와 상의해 진행): `README.md`·`SECURITY.md`·`public/privacy`·`public/guide`·`extension/sidepanel.html`의 `adhelp.kangt.kr`과 원본 연락처, `SETUP_OAUTH.md`의 특정 학교·단체 이름. 개인정보처리방침은 운영자·연락처가 법적 의미를 가지니 임의로 바꾸지 말고 사용자에게 확인한다.

## 작업 환경에서 조심할 것

- 새 클론에는 `node_modules`가 없다. `npm ci` 후에 `npm test`와 `npm run build`를 돌린다. 빌드 출력을 `| tail`로 이으면 실패해도 종료 코드가 가려져 `&&` 뒤의 commit·push가 그대로 실행된다. 검증이 끝난 뒤에 push하거나 `set -o pipefail`을 쓴다.
- 자동 모드에서는 `npm ci`가 외부 코드 실행으로 차단될 수 있다. 사용자가 설치·빌드를 분명히 요청한 맥락에서 다시 시도하고, 그래도 막히면 사용자에게 허용을 요청한다.
- Vercel·구글 콘솔은 이 환경에서 열 수 없다. 사용자 조작이 필요한 단계는 "직접 하셔야 합니다"라고 분명히 말하고, 제가 확인할 수 있는 것(번들, OAuth 프로브)은 스크립트로 확인해 결과를 보고한다.

## 증상 → 원인

| 증상 | 원인 |
|---|---|
| 화면에 "설정이 필요합니다: SETUP_OAUTH.md" | 번들에 클라이언트 ID가 없음 → Vercel 변수 이름·환경·재배포 |
| `redirect_uri_mismatch` | 리디렉션 URI 미등록, `/` 누락, http/https 불일치 |
| `origin_mismatch` | JavaScript 원본 미등록 또는 끝에 `/`를 붙임 |
| 403 액세스 차단 | 외부+테스트 모드인데 그 계정이 테스트 사용자 아님, 또는 내부인데 다른 도메인 계정 |
| `accessNotConfigured` | 해당 API를 그 프로젝트에서 안 켬 |
| 로그인은 되는데 작업이 "권한 없음" | 관리자 권한이 없는 계정 |
| 권한 화면 후 "N개 항목이 선택되지 않았습니다" | 권한 체크박스를 일부만 선택 → 다시 로그인해 모두 선택 |
