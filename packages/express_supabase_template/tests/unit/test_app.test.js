import assert from "node:assert";
import test from "node:test";
import app from "../../app/index.js";
test("Express app exports", (_t) => {
  assert.ok(app);
});
