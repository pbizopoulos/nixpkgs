import { authApiClient } from "@adonisjs/auth/plugins/api_client";
import app from "@adonisjs/core/services/app";
import { sessionApiClient } from "@adonisjs/session/plugins/api_client";
import { shieldApiClient } from "@adonisjs/shield/plugins/api_client";
import { apiClient } from "@japa/api-client";
import { assert } from "@japa/assert";
import { pluginAdonisJS } from "@japa/plugin-adonisjs";
import type { Config } from "@japa/runner/types";
/**
 * This file is imported by the "bin/test.ts" file to configure the
 * Japa runner.
 */
type RunnerConfig = Pick<Config, "plugins">;
export const runnerBySuite = (suites?: string[]): RunnerConfig => {
  if (!suites || suites.includes("functional")) {
    return {
      plugins: [
        assert(),
        apiClient(),
        pluginAdonisJS(app),
        sessionApiClient(app),
        shieldApiClient(),
        authApiClient(app),
      ],
    };
  }
  return {
    plugins: [assert(), pluginAdonisJS(app)],
  };
};
