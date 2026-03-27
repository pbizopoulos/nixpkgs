import type { HttpContext } from "@adonisjs/core/http";
import User from "#models/user";
import { isValidUsername } from "../validators/username.js";
export default class UsersController {
  async store({ request, response }: HttpContext) {
    const username = request.input("username");
    if (typeof username !== "string" || !isValidUsername(username)) {
      response.status(422);
      return { error: "username must be a valid lowercase slug" };
    }
    const existingUser = await User.findBy("username", username);
    if (existingUser) {
      response.status(409);
      return { error: "username already exists" };
    }
    const user = await User.create({ username });
    response.status(201);
    return { user };
  }
  async destroy({ params, response }: HttpContext) {
    const username = params.username;
    if (typeof username !== "string" || !isValidUsername(username)) {
      response.status(422);
      return { error: "username must be a valid lowercase slug" };
    }
    const user = await User.findBy("username", username);
    if (!user) {
      response.status(404);
      return { error: "user not found" };
    }
    await user.delete();
    return { deleted: true, username };
  }
}
