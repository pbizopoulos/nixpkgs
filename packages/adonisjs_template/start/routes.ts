import router from "@adonisjs/core/services/router";
import HealthController from "../app/controllers/health_controller.js";
import UsersController from "../app/controllers/users_controller.js";
const usersController = new UsersController();
const healthController = new HealthController();
router.on("/").render("pages/home").as("home");
router
  .post("/users/register", (ctx) => usersController.store(ctx))
  .as("users.register");
router
  .delete("/users/:username", (ctx) => usersController.destroy(ctx))
  .as("users.delete");
router.get("/health", (ctx) => healthController.show(ctx)).as("health");
