import type { HttpContext } from "@adonisjs/core/http";
import { serializeUser } from "../transformers/user_transformer.js";
export default class DashboardController {
  async show({ auth, view }: HttpContext) {
    const user = auth.use().getUserOrFail();
    return view.render("dashboard", {
      user: serializeUser(user),
    });
  }
}
