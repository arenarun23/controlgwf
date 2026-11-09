import { describe, expect, it } from "vitest";
import { adminRole, canUseApp } from "./adminrole";

describe("adminRole", () => {
  it("최고 관리자", () => {
    expect(adminRole({ isAdmin: true })).toBe("super");
  });
  it("위임 관리자", () => {
    expect(adminRole({ isDelegatedAdmin: true })).toBe("delegated");
  });
  it("최고 관리자가 위임 관리자보다 우선", () => {
    expect(adminRole({ isAdmin: true, isDelegatedAdmin: true })).toBe("super");
  });
  it("일반 계정", () => {
    expect(adminRole({})).toBe("none");
    expect(adminRole({ isAdmin: false, isDelegatedAdmin: false })).toBe("none");
  });
});

describe("canUseApp", () => {
  it("최고 관리자만 허용", () => {
    expect(canUseApp("super")).toBe(true);
    expect(canUseApp("delegated")).toBe(false);
    expect(canUseApp("none")).toBe(false);
  });
});
