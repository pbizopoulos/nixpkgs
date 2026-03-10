import { Elysia } from 'elysia'
import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.SUPABASE_URL || "";
const supabaseKey = process.env.SUPABASE_ANON_KEY || "";
const _supabase = createClient(supabaseUrl, supabaseKey);

const app = new Elysia()
    .get('/', () => 'Hello, Elysia with Supabase!')
    .listen(3000)

console.log(
    `🦊 Elysia is running at ${app.server?.hostname}:${app.server?.port}`
)
