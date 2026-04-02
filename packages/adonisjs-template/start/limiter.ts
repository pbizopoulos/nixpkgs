import limiter from "@adonisjs/limiter/services/main";
export const throttleLogin = limiter.define("login", (ctx) => {
  return limiter
    .allowRequests(5)
    .every("1 minute")
    .blockFor("5 minutes")
    .usingKey(`login:${ctx.request.ip()}`);
});
export const throttleSignup = limiter.define("signup", (ctx) => {
  return limiter
    .allowRequests(3)
    .every("1 minute")
    .blockFor("10 minutes")
    .usingKey(`signup:${ctx.request.ip()}`);
});
