import type { HttpContext } from "@adonisjs/core/http";
import User from "#models/user";
import { createUserValidator, deleteUserValidator } from "#validators/username";
import { serializeUser } from "../transformers/user_transformer.js";
export default class UsersController {
  async store({ request, response }: HttpContext) {
    const { username } = await request.validateUsing(createUserValidator);
    const existingUser = await User.findBy("username", username);
    if (existingUser) {
      response.status(409);
      return { error: "username already exists" };
    }
    const user = await User.create({ username });
    response.status(201);
    return { user: serializeUser(user) };
  }
  async destroy({ request }: HttpContext) {
    const {
      params: { username },
    } = await request.validateUsing(deleteUserValidator);
    const user = await User.findByOrFail("username", username);
    await user.delete();
    return { deleted: true, username };
  }
}
