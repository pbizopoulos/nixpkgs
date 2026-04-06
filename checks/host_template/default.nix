{
  inputs,
  pkgs,
  ...
}:
pkgs.testers.runNixOSTest rec {
  name = "template";
  nodes.machine = {
    environment.systemPackages = [
      pkgs.curl
    ];
    imports = [
      ../../modules/nixos/adonisjs.nix
    ];
    services.adonisjs-app = {
      inherit name;
      appKey = "01234567890123456789012345678901";
      appUrl = "http://127.0.0.1:3333";
      enable = true;
      executable = "adonisjs-template";
      host = "0.0.0.0";
      migrationExecutable = "adonisjs-template-migrate";
      nginx = {
        defaultVirtualHost = true;
        serverName = "machine";
      };
      package = inputs.self.packages.${pkgs.stdenv.system}.adonisjs-template;
      port = 3333;
    };
    virtualisation.memorySize = 8192;
  };
  testScript = ''
    machine.succeed("timeout 120 bash -lc 'until systemctl is-active --quiet nginx.service; do sleep 1; done'")
    machine.succeed("timeout 120 bash -lc 'until systemctl is-active --quiet postgresql.service; do sleep 1; done'")
    machine.succeed("timeout 120 bash -lc 'until systemctl is-active --quiet ${name}.service; do sleep 1; done'")
    machine.succeed("timeout 120 bash -lc 'until ss -ltn | grep -q :3333; do sleep 1; done'")
    machine.succeed("timeout 120 bash -lc 'until ss -ltn | grep -q :80; do sleep 1; done'")
    machine.succeed("timeout 120 bash -lc 'until curl -fsS http://127.0.0.1/health; do sleep 1; done'")
    machine.succeed("curl -fsS http://127.0.0.1/ | grep -F 'Build the app, not the scaffold.'")
    machine.succeed("""
      tmpdir=$(mktemp -d)
      trap 'rm -rf "$tmpdir"' EXIT
      curl -fsS -c "$tmpdir/cookies" http://127.0.0.1/register > "$tmpdir/register.html"
      csrf=$(grep -o "name='_csrf' value='[^']*'" "$tmpdir/register.html" | head -n1 | cut -d"'" -f4)
      test -n "$csrf"
      curl -fsS -L \
        -b "$tmpdir/cookies" \
        -c "$tmpdir/cookies" \
        http://127.0.0.1/register \
        --data-urlencode "_csrf=$csrf" \
        --data-urlencode "username=integration-user" \
        --data-urlencode "email=integration-user@example.com" \
        --data-urlencode "password=password123" \
        --data-urlencode "passwordConfirmation=password123" \
        | grep -F 'Welcome back, integration-user.'
      curl -fsS -b "$tmpdir/cookies" http://127.0.0.1/app | grep -F 'integration-user@example.com'
    """)
  '';
}
