{ inputs
  , pkgs
  , ... }:
  let
    allPackages = inputs.self.packages.${pkgs.stdenv.system};
    getPort = name:
      if pkgs.lib.hasInfix "spring_boot" name
        then "8080"
        else if pkgs.lib.hasInfix "adonisjs" name
          then "3333"
          else if pkgs.lib.hasInfix "flask" name
            then "8000"
            else if pkgs.lib.hasInfix "phoenix" name
              then "4000"
              else if pkgs.lib.hasInfix "quarkus" name
                then "8080"
                else if pkgs.lib.hasInfix "deno" name
                  then "8000"
                  else if pkgs.lib.hasInfix "symfony" name
                    then "8000"
                    else "3000";
    isWeb = name:
      pkgs.lib.any (suffix:
        pkgs.lib.hasInfix suffix name) [
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
    templateNames = builtins.filter (name:
      pkgs.lib.hasSuffix "_template" name) (builtins.attrNames allPackages);
    templatePackages = map (name:
      allPackages.${name}) templateNames;
  in pkgs.runCommand "check-all-templates" {
    buildInputs = templatePackages ++ [
      pkgs.curl
      pkgs.nodejs
      pkgs.postgresql
    ];
  } ''
    export HOME=$TMPDIR
    check_template() {
      name=$1
      is_web=$2
      port=$3
      pg_port=$4
      echo "Checking $name (PGPORT=$pg_port)..."
      if [ "$is_web" = "true" ]; then
        # Run in background with unique ports
        PGPORT=$pg_port $name > $name.log 2>&1 &
        PID=$!
        # Wait for server
        MAX_RETRIES=30
        COUNT=0
        SUCCESS=0
        while [ $COUNT -lt $MAX_RETRIES ]; do
          if curl -sSf http://localhost:$port > /dev/null 2>&1; then
            SUCCESS=1
            break
          fi
          sleep 2
          COUNT=$((COUNT + 1))
        done
        if [ $SUCCESS -eq 0 ]; then
          echo "$name failed to respond on port $port."
          echo "Last 20 lines of log:"
          tail -n 20 $name.log
          # find . -name "postgres.log" -exec echo "--- {} ---" \; -exec cat {} \;
          kill $PID || true
          return 1
        else
          echo "$name is up!"
          kill $PID || true
          return 0
        fi
      else
        # CLI/Source smoke test
        DEBUG=1 $name
        return $?
      fi
    }
    ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.lists.imap0 (index: name:
      ''
        check_template "${name}" "${if isWeb name then "true" else "false"}" "${getPort name}" "$((54322 + ${toString index}))" &
        # Limit concurrency to 8
        if [ $((( ${toString index} + 1 ) % 8)) -eq 0 ]; then
          wait
        fi
      '') templateNames)}
    wait
    touch $out
    ''
