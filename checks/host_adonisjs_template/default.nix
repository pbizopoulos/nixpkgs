{
  inputs,
  pkgs,
  ...
}:
pkgs.testers.runNixOSTest rec {
  name = "adonisjs_template";
  nodes.machine = {
    environment.systemPackages = [
      inputs.self.packages.${pkgs.stdenv.system}.${name}
      pkgs.curl
    ];
    networking.firewall.allowedTCPPorts = [
      80
    ];
    services = {
      nginx = {
        enable = true;
        virtualHosts.machine = {
          default = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:3333";
            recommendedProxySettings = true;
          };
        };
      };
      postgresql = {
        enable = true;
        ensureDatabases = [
          name
        ];
        ensureUsers = [
          {
            inherit name;
            ensureDBOwnership = true;
          }
        ];
      };
    };
    systemd.services.${name} = {
      after = [
        "network.target"
        "postgresql.service"
      ];
      environment = {
        APP_KEY = "01234567890123456789012345678901";
        APP_NAME = "AdonisJS Starter";
        APP_URL = "http://127.0.0.1:3333";
        DB_DATABASE = name;
        DB_HOST = "/run/postgresql";
        DB_PASSWORD = "unused";
        DB_PORT = "5432";
        DB_SSL = "false";
        DB_USER = name;
        HOST = "0.0.0.0";
        LOG_LEVEL = "info";
        NODE_ENV = "production";
        PORT = "3333";
        TZ = "UTC";
      };
      serviceConfig = {
        ExecStart = "${inputs.self.packages.${pkgs.stdenv.system}.${name}}/bin/${name}";
        Group = name;
        Restart = "always";
        RestartSec = 5;
        StateDirectory = name;
        User = name;
      };
      wantedBy = [
        "multi-user.target"
      ];
    };
    users = {
      groups.${name} = { };
      users.${name} = {
        group = name;
        home = "/var/lib/${name}";
        isSystemUser = true;
      };
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
      curl -fsS -X POST http://127.0.0.1/users/register \
        -H 'content-type: application/json' \
        --data '{\"username\":\"integration-user\"}' \
        | grep -F 'integration-user'
    """)
    machine.succeed("""
      curl -fsS -X DELETE http://127.0.0.1/users/integration-user \
        | grep -F '\"deleted\":true'
    """)
    machine.fail("curl -fsS -X DELETE http://127.0.0.1/users/integration-user")
  '';
}
