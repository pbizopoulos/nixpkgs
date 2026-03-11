import { Title } from "@solidjs/meta";
export default function Home() {
  return (
    <main>
      <Title>Hello World</Title>
      <h1>Hello world!</h1>
      <p>
        <a href="/auth.html">Open Supabase Auth UI</a>
      </p>
      <p>
        Visit{" "}
        <a href="https://start.solidjs.com" target="_blank" rel="noopener">
          start.solidjs.com
        </a>{" "}
        to learn how to build SolidStart apps.
      </p>
    </main>
  );
}
