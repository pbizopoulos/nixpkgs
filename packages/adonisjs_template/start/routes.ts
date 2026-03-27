import router from "@adonisjs/core/services/router";
import HealthController from "../app/controllers/health_controller.js";
import HomeController from "../app/controllers/home_controller.js";
import UsersController from "../app/controllers/users_controller.js";
const homeController = new HomeController();
const usersController = new UsersController();
const healthController = new HealthController();
router.get("/", (ctx) => homeController.index(ctx)).as("home");
router
  .post("/users/register", (ctx) => usersController.store(ctx))
  .as("users.register");
router
  .delete("/users/:username", (ctx) => usersController.destroy(ctx))
  .as("users.delete");
router.get("/health", (ctx) => healthController.show(ctx)).as("health");
