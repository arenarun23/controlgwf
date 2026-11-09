// 로그인한 계정이 관리자인지 가르는 순수 함수. 브라우저 전용 코드를 불러오지 않아 테스트할 수 있다.
export type AdminRole = "super" | "delegated" | "none";

export function adminRole(u: { isAdmin?: boolean; isDelegatedAdmin?: boolean }): AdminRole {
  if (u.isAdmin) return "super";
  if (u.isDelegatedAdmin) return "delegated";
  return "none";
}
