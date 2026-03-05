function runTests(): void {
  const x = 1;
  const y = 1;
  if (x + y !== 2) {
    throw new Error("test math failed");
  }
  console.log("test ... ok");
}
function main(): void {
  if (process.env.DEBUG === "1") {
    runTests();
  } else {
    console.log("Hello TypeScript!");
    const data = { message: "Hello, world!", language: "TypeScript" };
    console.log(JSON.stringify(data));
  }
}
main();
