import { spawn, execSync } from 'node:child_process';
import { readdirSync, existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const packages = readdirSync('packages').filter(pkg => pkg.endsWith('_template') || pkg.endsWith('_postgres_template'));

async function checkUrl(url, timeout = 60000) {
    const start = Date.now();
    while (Date.now() - start < timeout) {
        try {
            execSync(`curl -sSf ${url}`, { stdio: 'ignore' });
            return true;
        } catch (e) {
            await new Promise(resolve => setTimeout(resolve, 2000));
        }
    }
    return false;
}

function getPort(pkg, startJs) {
    if (pkg.includes('spring_boot')) return '8080';
    if (pkg.includes('adonisjs')) return '3333';
    if (pkg.includes('flask')) return '8000';
    if (pkg.includes('phoenix')) return '4000';
    if (pkg.includes('quarkus')) return '8080';
    if (pkg.includes('deno')) return '8000';
    if (pkg.includes('symfony')) return '8000';
    if (pkg.includes('svelte_template')) return '3000';
    if (pkg.includes('nextjs')) return '3000';
    if (pkg.includes('nuxt')) return '3000';
    if (pkg.includes('solidstart')) return '3000';
    if (pkg.includes('astro')) return '3000';
    if (pkg.includes('qwik')) return '3000';
    
    const portMatch = startJs.match(/port\s*[:=]\s*["']?(\d+)["']?/i);
    if (portMatch) return portMatch[1];
    
    return '3000'; // Default fallback
}

async function verifyPackage(pkg) {
    console.log(`\n--- Verifying ${pkg} ---`);
    
    const pkgPath = join('packages', pkg);
    const startJsPath = join(pkgPath, 'scripts/start.js');
    let isWeb = false;
    let startJs = '';

    if (existsSync(startJsPath)) {
        startJs = readFileSync(startJsPath, 'utf8');
        if (startJs.includes('spawn') || startJs.includes('exec') || startJs.includes('http') || startJs.includes('port')) {
            isWeb = true;
        }
    }

    if (pkg.includes('postgres') || pkg.includes('nextjs') || pkg.includes('express') || pkg.includes('flask') || pkg.includes('django') || pkg.includes('rails') || pkg.includes('deno') || pkg.includes('solidjs') || pkg.includes('svelte') || pkg.includes('hugo') || pkg.includes('quarkus')) {
        isWeb = true;
    }

    if (isWeb) {
        console.log(`${pkg} looks like a web framework. Starting server...`);
        let port = getPort(pkg, startJs);
        
        const child = spawn('nix', ['run', `.#${pkg}`], {
            stdio: 'inherit',
            detached: true
        });

        const ok = await checkUrl(`http://localhost:${port}`);
        
        // Cleanup process group
        try {
            process.kill(-child.pid, 'SIGKILL');
        } catch (e) {}

        if (ok) {
            console.log(`SUCCESS: ${pkg} server responded on port ${port}`);
        } else {
            console.log(`FAILURE: ${pkg} server did not respond on port ${port}`);
        }
    } else {
        console.log(`${pkg} looks like a CLI/Source template. Running smoke test...`);
        try {
            execSync(`DEBUG=1 nix run .#${pkg}`, { stdio: 'inherit' });
            console.log(`SUCCESS: ${pkg} smoke test passed`);
        } catch (e) {
            console.log(`FAILURE: ${pkg} smoke test failed`);
        }
    }
}

async function runAll() {
    for (const pkg of packages) {
        await verifyPackage(pkg);
    }
}

runAll();
