import fs from "node:fs";
import { calculateMetrics } from "mutation-testing-metrics";

const report = JSON.parse(
  fs.readFileSync("reports/mutation/mutation.json", "utf-8"),
);
const metrics = calculateMetrics(report.files);
console.log(JSON.stringify(metrics.metrics, null, 2));
