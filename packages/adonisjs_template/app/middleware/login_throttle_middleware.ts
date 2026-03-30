import type { HttpContext } from "@adonisjs/core/http";
import type { NextFn } from "@adonisjs/core/types/http";
import { throttleLogin } from "#start/limiter";
export default class LoginThrottleMiddleware {
  handle(ctx: HttpContext, next: NextFn) {
    return throttleLogin(ctx, next);
  }
}
