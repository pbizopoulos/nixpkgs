import { describe, expect, it } from "vitest";
import {
  mockNextNavigation,
  mockToast,
  mockUseAuth,
  suppressNavigationWarnings,
} from "./test-utils";

describe("test-utils", () => {
  it("should test mockUseAuth", () => {
    const auth = mockUseAuth({ user: { id: "custom" } as any });
    expect(auth.user.id).toBe("custom");
    auth.signOut();
    auth.openAuthModal();
    auth.closeAuthModal();
  });

  it("should test mockNextNavigation", () => {
    const nav = mockNextNavigation();
    const router = nav.useRouter();
    router.push("/");
    router.replace("/");
    router.back();
    router.forward();
    router.refresh();
    router.prefetch("/");

    expect(nav.usePathname()).toBe("/");
    const searchParams = nav.useSearchParams();
    searchParams.get("key");
    searchParams.getAll("key");
    searchParams.has("key");
    searchParams.forEach(() => {});
    searchParams.entries();
    searchParams.keys();
    searchParams.values();
    searchParams.toString();
  });

  it("should test mockToast", () => {
    const t = mockToast();
    t.toast.success("ok");
    t.toast.error("error");
    expect(t.mocks.toastSuccess).toHaveBeenCalledWith("ok");
    expect(t.mocks.toastError).toHaveBeenCalledWith("error");
  });

  it("should test suppressNavigationWarnings", () => {
    const sw = suppressNavigationWarnings();
    sw.setup();
    console.error("Not implemented: navigation");
    console.error({ toString: () => "Not implemented: navigation" });
    console.error("Real error");
    sw.cleanup();
  });
});
