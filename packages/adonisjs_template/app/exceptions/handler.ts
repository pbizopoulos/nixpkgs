import { ExceptionHandler } from "@adonisjs/core/http";
import app from "@adonisjs/core/services/app";
import type {
  StatusPageRange,
  StatusPageRenderer,
} from "@adonisjs/core/types/http";
export default class HttpExceptionHandler extends ExceptionHandler {
  protected debug = !app.inProduction;
  protected renderStatusPages = app.inProduction;
  protected statusPages: Record<StatusPageRange, StatusPageRenderer> = {
    "404": () =>
      `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1" /><title>Page Not Found</title></head><body><main><h1>Page Not Found</h1><p>The page you are looking for does not exist.</p><p><a href="/">Return Home</a></p></main></body></html>`,
    "500..599": () =>
      `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1" /><title>Server Error</title></head><body><main><h1>Something went wrong!</h1><p>An unexpected error has occurred.</p><p><a href="/">Return Home</a></p></main></body></html>`,
  };
}
