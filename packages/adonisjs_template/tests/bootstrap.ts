import app from "@adonisjs/core/services/app";
import { apiClient } from "@japa/api-client";
import { assert } from "@japa/assert";
import { pluginAdonisJS } from "@japa/plugin-adonisjs";
import type { Config } from "@japa/runner/types";
/**
 * This file is imported by the "bin/test.ts" file to configure the
 * Japa runner.
 */
// @ts-expect-error
export const runnerBySuite: Config["runnerBySuite"] = (
  suites: string[] | undefined,
) => {
  if (suites?.includes("functional")) {
    return {
      plugins: [assert(), apiClient(), pluginAdonisJS(app)],
    };
  }
  return {
    plugins: [assert(), pluginAdonisJS(app)],
  };
};
