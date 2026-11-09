# 배포 기록 — controlgwf (Admin Helper 사본)

이 저장소는 오픈소스 [Kang-T/admin-helper](https://github.com/Kang-T/admin-helper)(MIT)를 복사해 독립적으로 운영하는 사본이다.
원본 git 기록은 가져오지 않았고 `LICENSE`는 그대로 둔다. 일반 절차와 문제 해결은 `.claude/skills/admin-helper-deploy/SKILL.md`를 본다.

## 현재 구성

| 항목 | 값 |
|---|---|
| GitHub | https://github.com/arenarun23/controlgwf (`main`) |
| Vercel 프로젝트 | `controlgwf` (Hobby), Production 브랜치 `main` |
| 운영 주소 | https://controlgwf.vercel.app |
| 구글 클라우드 프로젝트 | `AdminHelper` |
| OAuth 클라이언트 ID | `15884462982-8i051djemgchsl2pta1vg3fnuaerbn6q.apps.googleusercontent.com` (공개돼도 되는 값. 보안 비밀번호는 쓰지 않음) |
| 동의 화면 | 내부 (구글 심사 불필요, 프로젝트 소유 조직 계정만 로그인) |
| Vercel 환경변수 | `VITE_GOOGLE_CLIENT_ID` (Production) — 빌드 때 번들에 포함 |

## 구글 클라우드(AdminHelper) 설정값

- 승인된 JavaScript 원본: `https://controlgwf.vercel.app` (끝 `/` 없이), `http://localhost:5173`
- 승인된 리디렉션 URI: `https://controlgwf.vercel.app/`, `http://localhost:5173/` (끝 `/` 포함)
- 켜야 하는 API: Admin SDK, Enterprise License Manager, Google Classroom, Cloud Identity

## 원본에서 바꾼 것

- 로그인 후 최고 관리자만 허용(`src/adminrole.ts`).
- 로그인 화면의 「사용 신청하기」 링크 제거(원본 운영자의 구글 설문이라 우리 사용자의 이메일이 그쪽으로 가기 때문).
- 「소스 코드」 링크를 이 저장소로 변경.

## 아직 원본 그대로인 것 (확인·수정 필요)

- `README.md`, `SECURITY.md`, `public/privacy/index.html`, `public/guide/index.html`, `extension/sidepanel.html`의 `adhelp.kangt.kr`과 원본 운영자 연락처. 개인정보처리방침은 운영자·연락처가 법적 의미를 가지므로 책임자 확인 뒤 수정한다.
- `SETUP_OAUTH.md`의 특정 학교·단체 이름.
- 개인정보처리방침의 「사용 신청 설문」 항목(설문을 제거했으므로 삭제 대상).

## 로그인할 수 있는 계정

내부 동의 화면이므로 **AdminHelper 프로젝트를 소유한 조직의 계정**이어야 한다.
이 사본은 로그인 직후 디렉터리 조회로 **최고 관리자(`isAdmin`)만** 통과시키고, 위임 관리자와 일반 계정은 로그아웃시킨 뒤
"최고 관리자 계정만 사용할 수 있습니다" 문구를 보여준다(`src/adminrole.ts`의 `canUseApp`). 안내용 확인이며, 실제 권한은 구글 API가 요청마다 검사한다.
위임 관리자도 허용하려면 `canUseApp`만 바꾼다. 원본은 위임 관리자도 허용한다.
다른 도메인(예: 다른 교육청)을 관리하려면 동의 화면을 외부 + 테스트 모드로 바꾸고 해당 관리자를 테스트 사용자로 추가한다(최대 100명).

## 변경 후 반영·확인 절차

1. 코드 변경: `npm ci` → `npm test` → `npm run build`가 모두 통과한 뒤 `main`에 push. Vercel이 자동 재배포한다.
2. 환경변수를 바꿨다면: Vercel → Settings → Environments → Production에서 수정 → Deployments에서 Redeploy(빌드 캐시 끄기).
3. 확인:

```bash
bash .claude/skills/admin-helper-deploy/scripts/check_deploy.sh \
  https://controlgwf.vercel.app \
  15884462982-8i051djemgchsl2pta1vg3fnuaerbn6q.apps.googleusercontent.com \
  http://localhost:5173/
```

## 진행 상태 (2026-11-09 기준)

- [x] 저장소 복사, GitHub 업로드, Vercel 배포
- [x] 원본 신청 설문 링크 제거
- [x] OAuth 클라이언트 생성, 배포 주소 리디렉션 URI 등록 확인
- [x] Vercel 환경변수 적용·재배포 — 배포 번들에 클라이언트 ID 포함 확인
- [ ] `http://localhost:5173/` 리디렉션 URI 등록(로컬 개발에서 로그인하려면 필요)
- [x] 최고 관리자만 통과(비관리자 계정 거부 동작 확인)
- [ ] 최고 관리자 계정으로 실제 로그인·사용자 조회 확인(직접 확인 필요)
- [ ] 원본 주소·연락처 문구 정리
