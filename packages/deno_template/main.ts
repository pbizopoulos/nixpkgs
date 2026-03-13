function runTests() {
  if (1 + 1 !== 2) {
    throw new Error("test math failed");
  }
  console.log("test ... ok");
}

function main() {
  if (Deno.env.get("DEBUG") === "1") {
    runTests();
  } else {
    Deno.serve((_req) => {
      return new Response("Hello World");
    });
  }
}

main();
