import type { HttpContext } from "@adonisjs/core/http";
import type { NextFn } from "@adonisjs/core/types/http";
export default class ForceJsonResponseMiddleware {
  async handle({ request }: HttpContext, next: NextFn) {
    /**
     * Force the request to be treated as a JSON request.
     * This is useful for API-first applications.
     */
    request.headers().accept = "application/json";
    return next();
  }
}
