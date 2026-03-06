const RED = "\x1b[31m";
const GREEN = "\x1b[32m";
const BLUE = "\x1b[34m";
const RESET = "\x1b[0m";
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
    for (let i = 1; i <= 100; i++) {
      if (i % 15 === 0) {
        console.log(`${RED}FizzBuzz${RESET}`);
      } else if (i % 3 === 0) {
        console.log(`${GREEN}Fizz${RESET}`);
      } else if (i % 5 === 0) {
        console.log(`${BLUE}Buzz${RESET}`);
      } else {
        console.log(i);
      }
    }
  }
}
main();
