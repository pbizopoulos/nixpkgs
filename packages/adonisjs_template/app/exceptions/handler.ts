import { ExceptionHandler, type HttpContext } from "@adonisjs/core/http";
import app from "@adonisjs/core/services/app";
import type {
  StatusPageRange,
  StatusPageRenderer,
} from "@adonisjs/core/types/http";
export default class HttpExceptionHandler extends ExceptionHandler {
  protected debug = !app.inProduction;
  protected renderStatusPages = app.inProduction;
  protected statusPages: Record<StatusPageRange, StatusPageRenderer> = {
    "404": (error, { view }) => view.render("errors/not-found", { error }),
    "500..599": (error, { view }) =>
      view.render("errors/server-error", { error }),
  };
  async handle(error: unknown, ctx: HttpContext) {
    return super.handle(error, ctx);
  }
  async report(error: unknown, ctx: HttpContext) {
    return super.report(error, ctx);
  }
}
