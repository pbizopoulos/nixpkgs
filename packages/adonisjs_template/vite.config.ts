import adonisjs from "@adonisjs/vite/client";
import { defineConfig } from "vite";
export default defineConfig({
  plugins: [
    adonisjs({
      entrypoints: ["resources/js/app.js"],
      reload: ["resources/views/**/*.edge"],
    }),
  ],
});
