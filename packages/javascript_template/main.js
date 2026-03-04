function runTests() {
  // biome-ignore lint/correctness/noConstantCondition: template
  if (1 + 1 === 2) {
    console.log("test math ... ok");
  } else {
    console.log("test math failed");
    process.exit(1);
  }
}
const debug = process.env.DEBUG;
if (debug === "1") {
  runTests();
} else {
  console.log("Hello JavaScript!");
}
