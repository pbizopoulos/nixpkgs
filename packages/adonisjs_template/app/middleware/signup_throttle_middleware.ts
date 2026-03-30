import type { HttpContext } from "@adonisjs/core/http";
import type { NextFn } from "@adonisjs/core/types/http";
import { throttleSignup } from "#start/limiter";
export default class SignupThrottleMiddleware {
  handle(ctx: HttpContext, next: NextFn) {
    return throttleSignup(ctx, next);
  }
}
