import type { HttpContext } from "@adonisjs/core/http";
import type { NextFn } from "@adonisjs/core/types/http";
export default class GuestMiddleware {
  async handle({ auth, response }: HttpContext, next: NextFn) {
    if (await auth.check()) {
      return response.redirect("/app");
    }
    return next();
  }
}
