import * as http from "node:http";
const server = http.createServer((_req, res) => {
  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end("Hello, TypeScript!");
});
const port = 3000;
server.listen(port, "0.0.0.0", () => {
  console.log(`Server running at http://0.0.0.0:${port}/`);
});
