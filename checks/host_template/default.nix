{
  inputs,
  pkgs,
  ...
}:
let
  mkNode =
    {
      backend,
      environmentFile,
      name,
    }:
    {
      config,
      ...
    }:
    {
      environment.systemPackages = [
        pkgs.curl
      ];
      imports = [
        (import ../../modules/nixos/template-app.nix {
          flake = inputs.self;
        })
      ];
      services.template-app = {
        inherit backend;
        inherit environmentFile;
        enable = true;
        host = "0.0.0.0";
        nginx = {
          defaultVirtualHost = true;
          enableACME = false;
          forceSSL = false;
          serverName = name;
        };
        package =
          inputs.self.packages.${pkgs.stdenv.system}.${config.services.template-app.packageAttrName};
        publicUrl = "http://127.0.0.1:${toString config.services.template-app.port}";
      };
      virtualisation.memorySize = 8192;
    };
  secretEnvironmentFiles = {
    adonis = pkgs.writeText "adonis-template-secrets.env" ''
      APP_KEY=01234567890123456789012345678901
    '';
    django = pkgs.writeText "django-template-secrets.env" ''
      SECRET_KEY=django-insecure-template-secret-key
    '';
  };
in
pkgs.testers.runNixOSTest {
  name = "template";
  nodes = {
    adonis = mkNode {
      backend = "adonisjs";
      environmentFile = secretEnvironmentFiles.adonis;
      name = "adonis";
    };
    django = mkNode {
      backend = "django";
      environmentFile = secretEnvironmentFiles.django;
      name = "django";
    };
  };
  testScript = ''
    import re
    import shlex
    import urllib.parse
    def request(machine, path, *, cookiejar, method="GET", form=None, follow=False):
        command = [
            "curl",
            "-sS",
            "-b",
            cookiejar,
            "-c",
            cookiejar,
        ]
        if follow:
            command.append("-L")
        if method == "POST":
            command.extend(
                [
                    "-H",
                    "Content-Type: application/x-www-form-urlencoded",
                    "--data",
                    urllib.parse.urlencode(form or {}),
                ],
            )
        command.extend(
            [
                f"http://127.0.0.1{path}",
                "-w",
                r"\n__STATUS__:%{http_code}\n__REDIRECT__:%{redirect_url}\n",
            ],
        )
        output = machine.succeed(" ".join(shlex.quote(part) for part in command))
        body, trailer = output.rsplit("\n__STATUS__:", maxsplit=1)
        status_text, redirect_url = trailer.split("\n__REDIRECT__:", maxsplit=1)
        return {
            "body": body,
            "redirect_url": redirect_url.strip(),
            "status": int(status_text.strip()),
        }
    def hidden_value(html, field_name):
        patterns = [
            rf'<input[^>]*name=["\\\']{re.escape(field_name)}["\\\'][^>]*value=["\\\']([^"\\\']+)["\\\']',
            rf'<input[^>]*value=["\\\']([^"\\\']+)["\\\'][^>]*name=["\\\']{re.escape(field_name)}["\\\']',
        ]
        for pattern in patterns:
            match = re.search(pattern, html)
            if match:
                return match.group(1)
        raise AssertionError(f"missing hidden field {field_name}")
    def smoke(machine, service_name, app_port, health_path="/health"):
        machine.succeed("timeout 120 bash -lc 'until systemctl is-active --quiet nginx.service; do sleep 1; done'")
        machine.succeed("timeout 120 bash -lc 'until systemctl is-active --quiet postgresql.service; do sleep 1; done'")
        machine.succeed(f"timeout 120 bash -lc 'until systemctl is-active --quiet {service_name}.service; do sleep 1; done'")
        machine.succeed(f"timeout 120 bash -lc 'until ss -ltn | grep -q :{app_port}; do sleep 1; done'")
        machine.succeed("timeout 120 bash -lc 'until ss -ltn | grep -q :80; do sleep 1; done'")
        machine.succeed(f"timeout 120 bash -lc 'until curl -fsS http://127.0.0.1{health_path}; do sleep 1; done'")
        machine.succeed("curl -fsS http://127.0.0.1/ | grep -F 'Build the app, not the scaffold.'")
    def auth_flow(machine, *, app_path, csrf_field, delete_path, unique):
        cookiejar = "/tmp/template-cookies.txt"
        username = f"starter-{unique}"
        email = f"{unique}@example.com"
        password = "S3cure-pass-1234"
        guest_response = request(machine, app_path, cookiejar=cookiejar)
        assert guest_response["status"] in (302, 303), guest_response
        assert "/login" in guest_response["redirect_url"], guest_response
        register_page = request(machine, "/register", cookiejar=cookiejar)
        registration = request(
            machine,
            "/register",
            cookiejar=cookiejar,
            method="POST",
            follow=True,
            form={
                csrf_field: hidden_value(register_page["body"], csrf_field),
                "email": email,
                "password": password,
                "password1": password,
                "password2": password,
                "passwordConfirmation": password,
                "password_confirmation": password,
                "username": username,
            },
        )
        assert registration["status"] == 200, registration
        assert username in registration["body"], registration["body"]
        assert email in registration["body"], registration["body"]
        logout_page = request(machine, app_path, cookiejar=cookiejar)
        logout_response = request(
            machine,
            "/logout",
            cookiejar=cookiejar,
            method="POST",
            follow=True,
            form={csrf_field: hidden_value(logout_page["body"], csrf_field)},
        )
        assert logout_response["status"] == 200, logout_response
        assert "signed out" in logout_response["body"].lower(), logout_response["body"]
        login_page = request(machine, "/login", cookiejar=cookiejar)
        login_response = request(
            machine,
            "/login",
            cookiejar=cookiejar,
            method="POST",
            follow=True,
            form={
                csrf_field: hidden_value(login_page["body"], csrf_field),
                "login": email,
                "password": password,
            },
        )
        assert login_response["status"] == 200, login_response
        assert "welcome back" in login_response["body"].lower(), login_response["body"]
        assert username in login_response["body"], login_response["body"]
        delete_page = request(machine, app_path, cookiejar=cookiejar)
        delete_response = request(
            machine,
            delete_path,
            cookiejar=cookiejar,
            method="POST",
            follow=True,
            form={csrf_field: hidden_value(delete_page["body"], csrf_field)},
        )
        assert delete_response["status"] == 200, delete_response
        assert "account has been deleted" in delete_response["body"].lower(), delete_response["body"]
    smoke(adonis, "adonisjs-template", 3333)
    auth_flow(adonis, app_path="/app", csrf_field="_csrf", delete_path="/account/delete", unique="adonis")
    smoke(django, "django_template", 8000)
    auth_flow(django, app_path="/app", csrf_field="csrfmiddlewaretoken", delete_path="/account/delete", unique="django")
  '';
}
