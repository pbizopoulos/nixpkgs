import { describe, expect, it, vi } from "vitest";
function inspectHandler(handler: object) {
  return handler as {
    debug: boolean;
    renderStatusPages: boolean;
    statusPages: Record<string, unknown>;
  };
}
async function loadHandler(inProduction: boolean) {
  vi.resetModules();
  vi.doMock("@adonisjs/core/services/app", () => ({
    default: { inProduction },
  }));
  return import("../../app/exceptions/handler.js");
}
describe("HttpExceptionHandler", () => {
  it("enables debug pages outside production", async () => {
    const { default: HttpExceptionHandler } = await loadHandler(false);
    const handler = inspectHandler(new HttpExceptionHandler());
    expect(handler.debug).toBe(true);
    expect(handler.renderStatusPages).toBe(false);
  });
  it("renders status pages in production", async () => {
    const { default: HttpExceptionHandler } = await loadHandler(true);
    const handler = inspectHandler(new HttpExceptionHandler());
    expect(handler.debug).toBe(false);
    expect(handler.renderStatusPages).toBe(true);
    expect(Object.keys(handler.statusPages)).toEqual(["404", "500..599"]);
  });
});
