import { createClient } from "@supabase/supabase-js";
import Fastify from "fastify";
const fastify = Fastify({
  logger: true,
});
const supabaseUrl = process.env.SUPABASE_URL || "";
const supabaseKey = process.env.SUPABASE_ANON_KEY || "";
const _supabase = createClient(supabaseUrl, supabaseKey);
fastify.get("/", async (_request, _reply) => {
  return { hello: "Fastify with Supabase!" };
});
const start = async () => {
  try {
    await fastify.listen({ port: 3000, host: "0.0.0.0" });
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};
start();
export default fastify;
