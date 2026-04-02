import type { ApplicationService } from "@adonisjs/core/types";
import edge from "edge.js";
import env from "#start/env";
export default class AppProvider {
  constructor(protected app: ApplicationService) {}
  /**
   * Register bindings to the container
   */
  register() {}
  /**
   * The container bindings have booted
   */
  async boot() {
    edge.global("appName", env.get("APP_NAME"));
    edge.global("supportEmail", env.get("MAIL_FROM_ADDRESS"));
  }
  /**
   * The application has been booted
   */
  async start() {}
  /**
   * The process has been started
   */
  async ready() {}
  /**
   * Preparing to shutdown the app
   */
  async shutdown() {}
}
