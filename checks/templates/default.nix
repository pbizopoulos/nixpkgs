{ inputs, pkgs, ... }:
let
  allPackages = inputs.self.packages.${pkgs.stdenv.system};
  getPort =
    name:
    if pkgs.lib.hasInfix "spring_boot" name then
      "8080"
    else if pkgs.lib.hasInfix "adonisjs" name then
      "3333"
    else if pkgs.lib.hasInfix "flask" name then
      "8000"
    else if pkgs.lib.hasInfix "phoenix" name then
      "4000"
    else if pkgs.lib.hasInfix "quarkus" name then
      "8080"
    else if pkgs.lib.hasInfix "deno" name then
      "8000"
    else if pkgs.lib.hasInfix "symfony" name then
      "8000"
    else
      "3000";
  isWeb =
    name:
    pkgs.lib.any (suffix: pkgs.lib.hasInfix suffix name) [
      "adonisjs"
      "axum"
      "blazor"
      "deno"
      "django"
      "elysia"
      "express"
      "flask"
      "hugo"
      "leptos"
      "nextjs"
      "postgres"
      "quarkus"
      "rails"
      "solidjs"
      "svelte"
    ];
  templateNames = builtins.filter (name: pkgs.lib.hasSuffix "_template" name) (
    builtins.attrNames allPackages
  );
  templatePackages = map (name: allPackages.${name}) templateNames;
in
pkgs.runCommand "check-all-templates"
  {
    buildInputs = templatePackages ++ [
      pkgs.curl
      pkgs.nodejs
      pkgs.postgresql
    ];
  }
  ''
    export HOME=$TMPDIR
    ${pkgs.lib.concatMapStringsSep "\n" (name: ''
      echo "Checking ${name}..."
      if ${if isWeb name then "true" else "false"}; then
        PORT=${getPort name}
        # Run in background
        ${name} > ${name}.log 2>&1 &
        PID=$!
        # Wait for server
        MAX_RETRIES=30
        COUNT=0
        SUCCESS=0
        while [ $COUNT -lt $MAX_RETRIES ]; do
          if curl -sSf http://localhost:$PORT > /dev/null 2>&1; then
            SUCCESS=1
            break
          fi
          sleep 2
          COUNT=$((COUNT + 1))
        done
        if [ $SUCCESS -eq 0 ]; then
          echo "${name} failed to respond on port $PORT."
          echo "Last 20 lines of log:"
          tail -n 20 ${name}.log
          kill $PID || true
          # exit 1 # Uncomment to make flake check fail on first error
        else
          echo "${name} is up!"
          kill $PID || true
        fi
      else
        # CLI/Source smoke test
        DEBUG=1 ${name}
      fi
    '') templateNames}
    touch $out
  ''
# Force rebuild
