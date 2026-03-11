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
      pkgs.util-linux
    ];
  } ''
    export HOME=$TMPDIR
    timings_dir=$TMPDIR/timings
    mkdir -p "$timings_dir"
    pids_file=$TMPDIR/template_pids
    : > "$pids_file"
    cleanup() {
      if [ -f "$pids_file" ]; then
        while read -r pid; do
          [ -n "$pid" ] || continue
          kill -TERM -- -"''${pid}" 2>/dev/null || true
          wait "$pid" 2>/dev/null || true
          kill -KILL -- -"''${pid}" 2>/dev/null || true
        done < "$pids_file"
      fi
    }
    trap cleanup EXIT INT TERM
    check_template() {
      name=$1
      is_web=$2
      port=$3
      pg_port=$4
      start_ms=$(date +%s%3N)
      ready_re='(listening|ready|server|localhost|127\\.0\\.0\\.1|http://|https://|started|running|port[[:space:]]+[0-9]+)'
      echo "Checking $name (PGPORT=$pg_port)..."
      if [ "$is_web" = "true" ]; then
        # Run in background with unique ports
        PGPORT=$pg_port setsid $name > $name.log 2>&1 &
        PID=$!
        echo "$PID" >> "$pids_file"
        # Wait for server
        MAX_RETRIES=60
        COUNT=0
        SUCCESS=0
        while [ $COUNT -lt $MAX_RETRIES ]; do
          if curl -sSf http://localhost:$port > /dev/null 2>&1; then
            SUCCESS=1
            break
          fi
          if grep -Eq "$ready_re" "$name.log" 2>/dev/null; then
            SUCCESS=1
            break
          fi
          sleep 2
          COUNT=$((COUNT + 1))
        done
        if [ $SUCCESS -eq 0 ]; then
          end_ms=$(date +%s%3N)
          echo "$name	start_timeout_ms=$((end_ms - start_ms))" > "$timings_dir/$name.txt"
          echo "$name failed to respond on port $port."
          echo "Last 20 lines of log:"
          tail -n 20 $name.log
          # find . -name "postgres.log" -exec echo "--- {} ---" \; -exec cat {} \;
          kill -TERM -- -"$PID" 2>/dev/null || true
          wait "$PID" 2>/dev/null || true
          kill -KILL -- -"$PID" 2>/dev/null || true
          return 1
        else
          end_ms=$(date +%s%3N)
          echo "$name	start_ready_ms=$((end_ms - start_ms))" > "$timings_dir/$name.txt"
          echo "$name is up!"
          kill -TERM -- -"$PID" 2>/dev/null || true
          wait "$PID" 2>/dev/null || true
          kill -KILL -- -"$PID" 2>/dev/null || true
          return 0
        fi
      else
        # CLI/Source smoke test
        DEBUG=1 $name
        end_ms=$(date +%s%3N)
        echo "$name	cli_ms=$((end_ms - start_ms))" > "$timings_dir/$name.txt"
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
    summary="$timings_dir/summary.tsv"
    : > "$summary"
    for f in "$timings_dir"/*.txt; do
      [ -e "$f" ] || continue
      line=$(cat "$f")
      name=$(printf "%s" "$line" | cut -f1)
      kv=$(printf "%s" "$line" | cut -f2)
      key=''${kv%%=*}
      val=''${kv##*=}
      status="cli"
      if [ "$key" = "start_ready_ms" ]; then
        status="ready"
      elif [ "$key" = "start_timeout_ms" ]; then
        status="timeout"
      fi
      printf "%s\t%s\t%s\n" "$name" "$val" "$status" >> "$summary"
    done
    sort -k2,2n "$summary" > "$timings_dir/summary_sorted.tsv"
    mkdir -p $out
    cp -r "$timings_dir" $out/
    ''
