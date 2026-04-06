{
  inputs,
  pkgs,
  ...
}:
let
  mkNode =
    {
      backend,
      name,
      packageAttrName,
      port,
      secretEnvironment,
    }:
    {
      environment.systemPackages = [
        pkgs.curl
      ];
      imports = [
        ../../modules/nixos/template-app.nix
      ];
      services.template-app = {
        inherit backend;
        inherit port;
        appName =
          if backend == "adonisjs" then
            "AdonisJS Starter"
          else if backend == "django" then
            "Django Starter"
          else
            "FastAPI Postgres Starter";
        enable = true;
        host = "0.0.0.0";
        name = packageAttrName;
        nginx = {
          defaultVirtualHost = true;
          serverName = name;
        };
        package = inputs.self.packages.${pkgs.stdenv.system}.${packageAttrName};
        publicUrl = "http://127.0.0.1:${toString port}";
      }
      // secretEnvironment;
      virtualisation.memorySize = 8192;
    };
in
pkgs.testers.runNixOSTest {
  name = "template";
  nodes = {
    adonis = mkNode {
      backend = "adonisjs";
      name = "adonis";
      packageAttrName = "adonisjs-template";
      port = 3333;
      secretEnvironment.appKey = "01234567890123456789012345678901";
    };
    django = mkNode {
      backend = "django";
      name = "django";
      packageAttrName = "django_template";
      port = 8000;
      secretEnvironment.secretKey = "django-insecure-template-secret-key";
    };
    fastapi = mkNode {
      backend = "fastapi-postgres";
      name = "fastapi";
      packageAttrName = "fastapi_postgres_template";
      port = 8000;
      secretEnvironment.secretKey = "fastapi-template-secret-key";
    };
  };
  testScript = ''
    def smoke(machine, service_name, app_port, health_path="/health"):
        machine.succeed("timeout 120 bash -lc 'until systemctl is-active --quiet nginx.service; do sleep 1; done'")
        machine.succeed("timeout 120 bash -lc 'until systemctl is-active --quiet postgresql.service; do sleep 1; done'")
        machine.succeed(f"timeout 120 bash -lc 'until systemctl is-active --quiet {service_name}.service; do sleep 1; done'")
        machine.succeed(f"timeout 120 bash -lc 'until ss -ltn | grep -q :{app_port}; do sleep 1; done'")
        machine.succeed("timeout 120 bash -lc 'until ss -ltn | grep -q :80; do sleep 1; done'")
        machine.succeed(f"timeout 120 bash -lc 'until curl -fsS http://127.0.0.1{health_path}; do sleep 1; done'")
        machine.succeed("curl -fsS http://127.0.0.1/ | grep -F 'Build the app, not the scaffold.'")
    smoke(adonis, "adonisjs-template", 3333)
    smoke(django, "django_template", 8000)
    smoke(fastapi, "fastapi_postgres_template", 8000)
  '';
}
