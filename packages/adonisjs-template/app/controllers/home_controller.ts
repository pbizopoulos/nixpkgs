import type { HttpContext } from "@adonisjs/core/http";
import StarterContentService from "#services/starter_content_service";
import { serializeUser } from "../transformers/user_transformer.js";
export default class HomeController {
  async show({ auth, view }: HttpContext) {
    const isAuthenticated = await auth.check();
    const starterContent = new StarterContentService().getHomePageCopy();
    return view.render("home", {
      isAuthenticated,
      starterContent,
      user: isAuthenticated && auth.user ? serializeUser(auth.user) : null,
    });
  }
}
