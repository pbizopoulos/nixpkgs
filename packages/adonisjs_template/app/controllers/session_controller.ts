import type { HttpContext } from "@adonisjs/core/http";
import User from "#models/user";
import { loginValidator } from "#validators/auth";
export default class SessionController {
  async create({ view }: HttpContext) {
    return view.render("auth/login");
  }
  async store({ auth, request, response, session }: HttpContext) {
    let payload: { login: string; password: string };
    try {
      payload = await request.validateUsing(loginValidator);
    } catch (error) {
      if (error && typeof error === "object" && "code" in error) {
        session.flashValidationErrors(error as never, true);
        session.flashExcept(["password"]);
        return response.redirect().back();
      }
      throw error;
    }
    try {
      const user = await User.verifyCredentials(
        payload.login,
        payload.password,
      );
      await auth.use().login(user);
      session.flash("success", `Welcome back, ${user.username}.`);
      return response.redirect("/app");
    } catch {
      session.flash("error", "The credentials you entered are invalid.");
      session.flashExcept(["password"]);
      return response.redirect().back();
    }
  }
  async destroy({ auth, response, session }: HttpContext) {
    await auth.use().logout();
    session.flash("success", "You have been signed out.");
    return response.redirect("/");
  }
}
