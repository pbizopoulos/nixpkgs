#!/usr/bin/env node
/*
|--------------------------------------------------------------------------
| Ace CLI Entry Point
|--------------------------------------------------------------------------
|
| The "ace.js" file is the entry point for running Ace commands.
| In AdonisJS v7, this file registers the "@poppinss/ts-exec" hook
| and then imports the "bin/console.js" file.
|
*/
import "@poppinss/ts-exec";
await import("./bin/console.js");
