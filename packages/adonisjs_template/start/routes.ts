import { HealthChecks, MemoryRSSCheck } from "@adonisjs/core/health";
import router from "@adonisjs/core/services/router";
import { DbCheck } from "@adonisjs/lucid/database";
import db from "@adonisjs/lucid/services/db";
import { isValidUsername } from "../lib/validation.js";
router.on("/").render("pages/home").as("home");
router
  .post("/users/register", async ({ request, response }) => {
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
  })
  .as("users.register");
router
  .delete("/users/:username", async ({ params, response }) => {
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
  })
  .as("users.delete");
router
  .get("/health", async ({ response }) => {
    const healthChecks = new HealthChecks().register([
      new DbCheck(db.connection()),
      new MemoryRSSCheck().warnWhenExceeds("400 mb").failWhenExceeds("600 mb"),
    ]);
    const report = await healthChecks.run();
    response.status(report.isHealthy ? 200 : 503);
    return report;
  })
  .as("health");
