{ inputs, pkgs, ... }:
let
  name = "nextjs_postgres_template";
  package = inputs.self.packages.${pkgs.stdenv.system}.${name};
in
pkgs.runCommand "check-${name}-server" { 
  buildInputs = [ package pkgs.curl pkgs.postgresql pkgs.nodejs ]; 
} ''
  export HOME=$TMPDIR
  # Run the template in the background
  ${name} &
  PID=$!

  # Wait for the server to respond
  MAX_RETRIES=60
  COUNT=0
  until curl -sSf http://localhost:3000 > /dev/null || [ $COUNT -eq $MAX_RETRIES ]; do
    echo "Waiting for Next.js server..."
    sleep 2
    COUNT=$((COUNT + 1))
  done

  if [ $COUNT -eq $MAX_RETRIES ]; then
    echo "Next.js server failed to start"
    kill $PID
    exit 1
  fi

  echo "Next.js server is up!"
  kill $PID
  touch $out
''
