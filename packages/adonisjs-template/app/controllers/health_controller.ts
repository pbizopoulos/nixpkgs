import { HealthChecks, MemoryRSSCheck } from "@adonisjs/core/health";
import type { HttpContext } from "@adonisjs/core/http";
import { DbCheck } from "@adonisjs/lucid/database";
import db from "@adonisjs/lucid/services/db";
export default class HealthController {
  async show({ response }: HttpContext) {
    const healthChecks = new HealthChecks().register([
      new DbCheck(db.connection()),
      new MemoryRSSCheck().warnWhenExceeds("400 mb").failWhenExceeds("600 mb"),
    ]);
    const report = await healthChecks.run();
    response.status(report.isHealthy ? 200 : 503);
    return report;
  }
}
