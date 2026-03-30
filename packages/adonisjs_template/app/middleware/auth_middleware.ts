import type { HttpContext } from "@adonisjs/core/http";
import type { NextFn } from "@adonisjs/core/types/http";
export default class AuthMiddleware {
  async handle({ auth, response, session }: HttpContext, next: NextFn) {
    if (!(await auth.check())) {
      session.flash("error", "Sign in to continue.");
      return response.redirect("/login");
    }
    return next();
  }
}
