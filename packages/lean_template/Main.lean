def main : IO Unit := do
  let debug ← IO.getEnv "DEBUG"
  if debug == some "1" then
    IO.println "test ... ok"
  else
    IO.println "Hello, Lean!"
