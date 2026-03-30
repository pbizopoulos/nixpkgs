import app from "@adonisjs/core/services/app";
import { defineConfig } from "@adonisjs/shield";
const shieldConfig = defineConfig({
  csp: {
    enabled: false,
    directives: {},
    reportOnly: false,
  },
  csrf: {
    enabled: true,
    exceptRoutes: ["/health"],
    enableXsrfCookie: false,
    methods: ["POST", "PUT", "PATCH", "DELETE"],
  },
  xFrame: {
    enabled: true,
    action: "DENY",
  },
  hsts: {
    enabled: app.inProduction,
    maxAge: "180 days",
  },
  contentTypeSniffing: {
    enabled: true,
  },
});
export default shieldConfig;
