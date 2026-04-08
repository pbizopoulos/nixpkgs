import type { HttpContext } from "@adonisjs/core/http";
import mail from "@adonisjs/mail/services/main";
import WelcomeMail from "#mails/welcome_mail";
import User from "#models/user";
import { registerUserValidator } from "#validators/auth";
export default class UsersController {
  async create({ view }: HttpContext) {
    return view.render("auth/register");
  }
  async store({ auth, request, response, session }: HttpContext) {
    let payload: {
      email: string;
      password: string;
      passwordConfirmation: string;
      username: string;
    };
    try {
      payload = await request.validateUsing(registerUserValidator);
    } catch (error) {
      if (
        error &&
        typeof error === "object" &&
        "code" in error &&
        error.code === "E_VALIDATION_ERROR"
      ) {
        session.flashValidationErrors(error as never, true);
        session.flashExcept(["password", "passwordConfirmation"]);
        return response.redirect().back();
      }
      throw error;
    }
    if (payload.password !== payload.passwordConfirmation) {
      session.flashErrors({
        passwordConfirmation: "Password confirmation must match the password.",
      });
      session.flashExcept(["password", "passwordConfirmation"]);
      return response.redirect().back();
    }
    const existingUser = await User.query()
      .where("email", payload.email)
      .orWhere("username", payload.username)
      .first();
    if (existingUser) {
      session.flashErrors({
        [existingUser.email === payload.email ? "email" : "username"]:
          "This value is already taken.",
      });
      session.flashExcept(["password", "passwordConfirmation"]);
      return response.redirect().back();
    }
    const user = await User.create({
      email: payload.email,
      password: payload.password,
      username: payload.username,
    });
    await mail.send(new WelcomeMail(user));
    await auth.use().login(user);
    session.flash(
      "success",
      `Welcome, ${user.username}. Your account is ready.`,
    );
    return response.redirect("/app");
  }
  async destroy({ auth, response, session }: HttpContext) {
    const user = auth.use().getUserOrFail();
    const username = user.username;
    await auth.use().logout();
    await user.delete();
    session.flash("success", `The ${username} account has been deleted.`);
    return response.redirect("/");
  }
}
