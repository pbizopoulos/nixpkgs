import { defineConfig, drivers } from "@adonisjs/core/hash";
const hashConfig = defineConfig({
  default: "scrypt",
  list: {
    scrypt: drivers.scrypt({}),
  },
});
export default hashConfig;
