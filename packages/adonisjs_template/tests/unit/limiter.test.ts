import limiter from "@adonisjs/limiter/services/main";
import { test } from "@japa/runner";
import { throttleLogin, throttleSignup } from "../../start/limiter.js";
function createContext(ipAddress: string) {
  const headers: Record<string, number | string> = {};
  return {
    ctx: {
      request: {
        ip() {
          return ipAddress;
        },
      },
      response: {
        header(name: string, value: number | string) {
          headers[name] = value;
        },
      },
    },
    headers,
  };
}
test.group("Rate limiters", (group) => {
  group.each.setup(async () => {
    await limiter.clear();
    return async () => {
      await limiter.clear();
    };
  });
  test("login limiter allows five requests before blocking", async ({
    assert,
  }) => {
    const { ctx, headers } = createContext("203.0.113.10");
    const { ctx: otherCtx } = createContext("203.0.113.12");
    assert.equal(throttleLogin.name, "loginThrottle");
    for (let attempt = 0; attempt < 5; attempt++) {
      const result = await throttleLogin(
        ctx as never,
        async () => `login-${attempt}`,
      );
      assert.equal(result, `login-${attempt}`);
      assert.equal(headers["X-RateLimit-Limit"], 5);
      assert.equal(headers["X-RateLimit-Remaining"], 4 - attempt);
    }
    try {
      await throttleLogin(ctx as never, async () => "blocked");
      assert.fail("Expected the login limiter to block the sixth request");
    } catch (error) {
      assert.propertyVal(error, "status", 429);
      assert.equal((error as any).message, "Too many requests");
      assert.isAtLeast((error as any).response.availableIn, 240);
    }
    const freshIpResult = await throttleLogin(
      otherCtx as never,
      async () => "fresh-ip-login",
    );
    assert.equal(freshIpResult, "fresh-ip-login");
  });
  test("signup limiter allows three requests before blocking", async ({
    assert,
  }) => {
    const { ctx, headers } = createContext("203.0.113.11");
    const { ctx: otherCtx } = createContext("203.0.113.13");
    assert.equal(throttleSignup.name, "signupThrottle");
    for (let attempt = 0; attempt < 3; attempt++) {
      const result = await throttleSignup(
        ctx as never,
        async () => `signup-${attempt}`,
      );
      assert.equal(result, `signup-${attempt}`);
      assert.equal(headers["X-RateLimit-Limit"], 3);
      assert.equal(headers["X-RateLimit-Remaining"], 2 - attempt);
    }
    try {
      await throttleSignup(ctx as never, async () => "blocked");
      assert.fail("Expected the signup limiter to block the fourth request");
    } catch (error) {
      assert.propertyVal(error, "status", 429);
      assert.equal((error as any).message, "Too many requests");
      assert.isAtLeast((error as any).response.availableIn, 540);
    }
    const freshIpResult = await throttleSignup(
      otherCtx as never,
      async () => "fresh-ip-signup",
    );
    assert.equal(freshIpResult, "fresh-ip-signup");
  });
});
