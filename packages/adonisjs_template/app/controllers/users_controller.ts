import type { HttpContext } from "@adonisjs/core/http";
import User from "#models/user";
import { createUsernameValidator } from "#validators/username";
import { serializeUser } from "../transformers/user_transformer.js";
export default class UsersController {
  async store({ request, response }: HttpContext) {
    const { username } = await request.validateUsing(createUsernameValidator);
    const existingUser = await User.findBy("username", username);
    if (existingUser) {
      response.status(409);
      return { error: "username already exists" };
    }
    const user = await User.create({ username });
    response.status(201);
    return { user: serializeUser(user) };
  }
  async destroy({ params }: HttpContext) {
    const username = params.username;
    const { username: validatedUsername } =
      await createUsernameValidator.validate({ username });
    const user = await User.findByOrFail("username", validatedUsername);
    await user.delete();
    return { deleted: true, username: validatedUsername };
  }
}
