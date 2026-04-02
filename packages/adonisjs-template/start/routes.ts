import router from "@adonisjs/core/services/router";
import { middleware } from "./kernel.js";
const DashboardController = () => import("#controllers/dashboard_controller");
const HomeController = () => import("#controllers/home_controller");
const HealthController = () => import("#controllers/health_controller");
const SessionController = () => import("#controllers/session_controller");
const UsersController = () => import("#controllers/users_controller");
router.get("/", [HomeController, "show"]).as("home");
router
  .get("/register", [UsersController, "create"])
  .use(middleware.guest())
  .as("register.show");
router
  .post("/register", [UsersController, "store"])
  .use([middleware.guest(), middleware.throttleSignup()])
  .as("register.store");
router
  .get("/login", [SessionController, "create"])
  .use(middleware.guest())
  .as("login.show");
router
  .post("/login", [SessionController, "store"])
  .use([middleware.guest(), middleware.throttleLogin()])
  .as("login.store");
router
  .post("/logout", [SessionController, "destroy"])
  .use(middleware.auth())
  .as("logout");
router
  .post("/account/delete", [UsersController, "destroy"])
  .use(middleware.auth())
  .as("account.delete");
router
  .get("/app", [DashboardController, "show"])
  .use(middleware.auth())
  .as("dashboard.show");
router.get("/health", [HealthController, "show"]).as("health");
