import type { HttpContext } from "@adonisjs/core/http";
import { serializeUser } from "../transformers/user_transformer.js";
export default class HomeController {
  async show({ auth, view }: HttpContext) {
    const isAuthenticated = await auth.check();
    return view.render("home", {
      isAuthenticated,
      user: isAuthenticated && auth.user ? serializeUser(auth.user) : null,
    });
  }
}
