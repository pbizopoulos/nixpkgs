import { defineConfig, transports } from "@adonisjs/mail";
import type { InferMailers } from "@adonisjs/mail/types";
import env from "#start/env";
const mailConfig = defineConfig({
  default: env.get("MAIL_MAILER"),
  from: {
    address: env.get("MAIL_FROM_ADDRESS"),
    name: env.get("MAIL_FROM_NAME"),
  },
  globals: {
    brandName: env.get("APP_NAME"),
  },
  mailers: {
    smtp: transports.smtp({ jsonTransport: true } as never),
  },
});
export default mailConfig;
declare module "@adonisjs/mail/types" {
  interface MailersList extends InferMailers<typeof mailConfig> {}
}
