import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";
function getStartJsFiles(dir) {
  let results = [];
  const list = readdirSync(dir);
  for (const file of list) {
    const fullPath = join(dir, file);
    const stat = statSync(fullPath);
    if (stat?.isDirectory()) {
      results = results.concat(getStartJsFiles(fullPath));
    } else if (file === "start.js" && fullPath.includes("_postgres_template")) {
      results.push(fullPath);
    }
  }
  return results;
}
const templates = getStartJsFiles("packages");
for (const file of templates) {
  let content = readFileSync(file, "utf8");
  const improvedStartPostgres = `function startPostgres(workDir) {
  const pgData = join(workDir, ".pgdata");
  const pgPort = process.env.PGPORT || "54322";
  const pgHost = process.env.PGHOST || "127.0.0.1";
  if (!existsSync(pgData)) {
    console.log("Initializing Postgres database...");
    mkdirSync(pgData, { recursive: true });
    execSync(\`initdb -D \${pgData} --auth=trust\`, { stdio: "inherit" });
  }
  console.log(\`Starting Postgres on \${pgHost}:\${pgPort}...\`);
  try {
    const pgLog = join(workDir, "postgres.log");
    execSync(\`pg_ctl -D \${pgData} -l \${pgLog} -o "-p \${pgPort} -h \${pgHost}" start\`, { stdio: "inherit" });
  } catch (e) {
    console.log("Postgres might already be running or failed to start.");
  }
  const stopPostgres = () => {
    console.log("Stopping Postgres...");
    try {
      execSync(\`pg_ctl -D \${pgData} stop\`, { stdio: "inherit" });
    } catch (e) {}
  };
  process.on("SIGINT", stopPostgres);
  process.on("SIGTERM", stopPostgres);
  process.on("exit", stopPostgres);
}`;
  const functionStartMarker = "function startPostgres(workDir) {";
  const functionEndMarker = '  process.on("exit", stopPostgres);\n}';
  const startIndex = content.indexOf(functionStartMarker);
  const endIndex = content.indexOf(functionEndMarker, startIndex);
  if (startIndex !== -1 && endIndex !== -1) {
    const actualEndIndex = endIndex + functionEndMarker.length;
    content =
      content.substring(0, startIndex) +
      improvedStartPostgres +
      content.substring(actualEndIndex);
    writeFileSync(file, content);
    console.log(`Improved ${file}`);
  } else {
    console.log(`Could not find function bounds in ${file}`);
  }
}
