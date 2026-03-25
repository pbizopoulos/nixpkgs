import { rmSync } from "node:fs";
for (const path of [".next", "build", "coverage", "reports", ".stryker-tmp"]) {
  rmSync(path, { recursive: true, force: true });
}
