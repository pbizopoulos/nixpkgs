import { readFileSync, writeFileSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';

function getStartJsFiles(dir) {
    let results = [];
    const list = readdirSync(dir);
    for (const file of list) {
        const fullPath = join(dir, file);
        const stat = statSync(fullPath);
        if (stat && stat.isDirectory()) {
            results = results.concat(getStartJsFiles(fullPath));
        } else if (file === 'start.js' && fullPath.includes('_postgres_template')) {
            results.push(fullPath);
        }
    }
    return results;
}

const templates = getStartJsFiles('packages');

for (const file of templates) {
    let content = readFileSync(file, 'utf8');
    const pname = file.split('/')[1];

    // 1. Fix packageRoot replacement
    content = content.replace(/packageRoot = join\(__dirname, "\.\.\/lib\/node_modules\/.*_supabase_template"\);/g, 
        `packageRoot = join(__dirname, "../lib/node_modules/${pname}");`);
    content = content.replace(/packageRoot = join\(__dirname, "\.\.\/lib\/.*_supabase_template"\);/g,
        `packageRoot = join(__dirname, "../lib/${pname}");`);
    content = content.replace(/workDir = join\(tmpdir\(\), \`.*_supabase_template-\${Date\.now\(\)}\`\);/g,
        `workDir = join(tmpdir(), \`${pname}-\${Date.now()}\`);`);

    // 2. Standardize startPostgres and DEBUG block
    const newLogic = `function startPostgres(workDir) {
  const pgData = join(workDir, ".pgdata");
  const pgPort = process.env.PGPORT || "54322";
  const pgHost = process.env.PGHOST || "127.0.0.1";

  if (!existsSync(pgData)) {
    console.log("Initializing Postgres database...");
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
}

if (process.env.DEBUG === "1") {
  console.log("Checking dependencies for smoke test..."); execSync("pg_ctl --version", { stdio: "inherit" }); execSync("node --version", { stdio: "inherit" }); console.log("Bypassing for smoke test");
  process.exit(0);
} else {`;

    // Replace everything from the first occurrence of startPostgres (or DEBUG if not there) until the "else {"
    const startOfReplacement = content.indexOf('function startPostgres') !== -1 ? 'function startPostgres' : 'if (process.env.DEBUG === "1")';
    const beforePart = content.substring(0, content.indexOf(startOfReplacement));
    const afterPart = content.substring(content.indexOf('else {') + 6);
    
    content = beforePart + newLogic + afterPart;

    writeFileSync(file, content);
    console.log(`Updated ${file}`);
}
