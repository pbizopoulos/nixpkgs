import router from "@adonisjs/core/services/router";
const HealthController = () => import("#controllers/health_controller");
const UsersController = () => import("#controllers/users_controller");
router.on("/").render("home").as("home");
router.post("/users/register", [UsersController, "store"]).as("users.register");
router
  .delete("/users/:username", [UsersController, "destroy"])
  .as("users.delete");
router.get("/health", [HealthController, "show"]).as("health");
