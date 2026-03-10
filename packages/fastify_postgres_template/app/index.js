import { createClient } from "@supabase/supabase-js";
import Fastify from "fastify";
const fastify = Fastify({
  logger: true,
});
const postgresUrl = process.env.POSTGRES_URL || "";
const postgresKey = process.env.POSTGRES_ANON_KEY || "";
const _postgres = createClient(postgresUrl, postgresKey);
fastify.get("/", async (_request, _reply) => {
  return { hello: "Fastify with Postgres!" };
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
