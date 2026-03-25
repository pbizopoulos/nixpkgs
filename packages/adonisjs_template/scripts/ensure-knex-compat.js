import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = join(__dirname, "..");
const shimPath = join(projectRoot, "node_modules/knex/lib/dialects/sqlite3.js");
const targetPath = join(
  projectRoot,
  "node_modules/knex/lib/dialects/sqlite3/index.js",
);
if (!existsSync(shimPath) && existsSync(targetPath)) {
  mkdirSync(dirname(shimPath), { recursive: true });
  writeFileSync(shimPath, "module.exports = require('./sqlite3/index.js');\n");
}
const esmEntrypointPath = join(projectRoot, "node_modules/knex/knex.mjs");
if (existsSync(esmEntrypointPath)) {
  writeFileSync(
    esmEntrypointPath,
    `// Knex.js
// --------------
//     (c) 2013-present Tim Griesser
//     Knex may be freely distributed under the MIT license.
//     For details and documentation:
//     http://knexjs.org
import knex from './lib/index.js';
knex.knex = knex;
knex.default = knex;
export { knex };
export default knex;
`,
  );
}
