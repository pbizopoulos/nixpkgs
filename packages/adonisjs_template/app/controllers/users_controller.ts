import type { HttpContext } from "@adonisjs/core/http";
import User from "#models/user";
import UserRegistered from "../events/user_registered.js";
import { createUsernameValidator } from "../validators/username.js";
export default class UsersController {
  async store({ request, response }: HttpContext) {
    const { username } = await request.validateUsing(createUsernameValidator);
    const existingUser = await User.findBy("username", username);
    if (existingUser) {
      response.status(409);
      return { error: "username already exists" };
    }
    const user = await User.create({ username });
    await UserRegistered.dispatch(user);
    response.status(201);
    return { user };
  }
  async destroy({ params }: HttpContext) {
    const username = params.username;
    /**
     * Use validator for consistency even for params
     */
    const { username: validatedUsername } =
      await createUsernameValidator.validate({ username });
    const user = await User.findByOrFail("username", validatedUsername);
    await user.delete();
    return { deleted: true, username: validatedUsername };
  }
}
