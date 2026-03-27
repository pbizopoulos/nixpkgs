import type { HttpContext } from "@adonisjs/core/http";
import db from "@adonisjs/lucid/services/db";
import { isValidUsername } from "#validators/username";
export default class UsersController {
  async store({ request, response }: HttpContext) {
    const username = request.input("username");
    if (typeof username !== "string" || !isValidUsername(username)) {
      response.status(422);
      return { error: "username must be a valid lowercase slug" };
    }
    const existingUser = await db
      .from("users")
      .select("id", "username")
      .where("username", username)
      .first();
    if (existingUser) {
      response.status(409);
      return { error: "username already exists" };
    }
    await db.table("users").insert({ username });
    const user = await db
      .from("users")
      .select("id", "username")
      .where("username", username)
      .first();
    response.status(201);
    return { user };
  }
  async destroy({ params, response }: HttpContext) {
    const username = params.username;
    if (typeof username !== "string" || !isValidUsername(username)) {
      response.status(422);
      return { error: "username must be a valid lowercase slug" };
    }
    const existingUser = await db
      .from("users")
      .select("id")
      .where("username", username)
      .first();
    if (!existingUser) {
      response.status(404);
      return { error: "user not found" };
    }
    await db.from("users").where("username", username).delete();
    return { deleted: true, username };
  }
}
