function runTests(): void {
  const x = 1;
  const y = 1;
  if (x + y !== 2) {
    throw new Error("test math failed");
  }
  console.log("test math ... ok");
}
function main(): void {
  if (process.env.DEBUG === "1") {
    runTests();
  } else {
    console.log("Hello TypeScript!");
  }
}
main();
