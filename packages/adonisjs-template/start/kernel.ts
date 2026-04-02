import router from "@adonisjs/core/services/router";
import server from "@adonisjs/core/services/server";
server.errorHandler(() => import("#exceptions/handler"));
server.use([() => import("@adonisjs/static/static_middleware")]);
router.use([
  () => import("@adonisjs/core/bodyparser_middleware"),
  () => import("@adonisjs/session/session_middleware"),
  () => import("@adonisjs/shield/shield_middleware"),
  () => import("@adonisjs/auth/initialize_auth_middleware"),
]);
export const middleware = router.named({
  auth: () => import("#middleware/auth_middleware"),
  guest: () => import("#middleware/guest_middleware"),
  throttleLogin: () => import("#middleware/login_throttle_middleware"),
  throttleSignup: () => import("#middleware/signup_throttle_middleware"),
});
