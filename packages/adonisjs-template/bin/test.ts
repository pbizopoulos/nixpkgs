import "reflect-metadata";
import { Ignitor, prettyPrintError } from "@adonisjs/core";
import { configure, processCLIArgs, run } from "@japa/runner";
/*
|--------------------------------------------------------------------------
| Test entry point
|--------------------------------------------------------------------------
*/
const APP_ROOT = new URL("../", import.meta.url);
const IS_COMPILED_RUNNER = import.meta.url.endsWith("/build/bin/test.js");
const rewriteCompiledSuiteFile = (file: string) =>
  file.startsWith("build/")
    ? file.replace(/\.ts$/u, ".js")
    : `build/${file.replace(/\.ts$/u, ".js")}`;
const IMPORTER = (filePath: string | URL) => {
  const specifier = filePath instanceof URL ? filePath.href : filePath;
  if (specifier.startsWith("./") || specifier.startsWith("../")) {
    return import(new URL(specifier, APP_ROOT).href);
  }
  return import(specifier);
};
new Ignitor(APP_ROOT, { importer: IMPORTER })
  .tap((app) => {
    app.booting(async () => {
      await import("#start/env");
    });
  })
  .testRunner()
  .configure(async (app) => {
    const { runnerBySuite } = await import("../tests/bootstrap.js");
    const cliArgs = process.argv.slice(2);
    const suites = app.rcFile.tests.suites.map(
      (suite: (typeof app.rcFile.tests.suites)[number]) => ({
        ...suite,
        files: IS_COMPILED_RUNNER
          ? (Array.isArray(suite.files) ? suite.files : [suite.files]).map(
              (file: string) => rewriteCompiledSuiteFile(file),
            )
          : suite.files,
      }),
    );
    const selectedSuites = suites
      .map((suite) => suite.name)
      .filter((suiteName) => cliArgs.includes(suiteName));
    processCLIArgs(cliArgs);
    configure({
      ...app.rcFile.tests,
      suites,
      // biome-ignore lint/suspicious/noExplicitAny: bypass
      ...runnerBySuite(selectedSuites.length > 0 ? selectedSuites : undefined),
      importer: IMPORTER,
    });
  })
  .run(() => run())
  .catch((error) => {
    process.exitCode = 1;
    prettyPrintError(error);
  });
