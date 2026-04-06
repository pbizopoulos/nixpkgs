{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}:
let
  app = {
    inherit
      framework
      packageAttrName
      packageName
      port
      runtimeUser
      ;
  };
  framework = "adonisjs";
  hostName = baseNameOf ./.;
  opensshAuthorizedKeyFiles = [
    ./../../prm/developer.pub
  ];
  packageAttrName =
    if framework == "adonisjs" then
      "adonisjs-template"
    else if framework == "django" then
      "django_template"
    else
      "fastapi_postgres_template";
  packageName = packageAttrName;
  port = if framework == "adonisjs" then 3333 else 8000;
  runtimeUser = packageName;
in
{
  age.secrets.secrets-env = {
    file = ../../secrets/secrets.age;
    group = app.runtimeUser;
    owner = app.runtimeUser;
  };
  boot = {
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = true;
  };
  disko.devices = {
    disk.main = {
      content = {
        partitions = {
          esp = {
            content = {
              format = "vfat";
              mountpoint = "/boot";
              type = "filesystem";
            };
            end = "512M";
            type = "EF00";
          };
          nix = {
            content = {
              format = "ext4";
              mountpoint = "/nix";
              type = "filesystem";
            };
            size = "100%";
          };
          persistent = {
            content = {
              format = "ext4";
              mountpoint = "/persistent";
              type = "filesystem";
            };
            size = "40G";
          };
          swap = {
            content.type = "swap";
            size = "1G";
          };
        };
        type = "gpt";
      };
      device = "/dev/sda";
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "mode=755"
      ];
    };
  };
  environment.systemPackages = [ ];
  fileSystems."/persistent".neededForBoot = true;
  imports = [
    ../../modules/nixos/adonisjs.nix
    ../../modules/nixos/django.nix
    ../../modules/nixos/fastapi-postgres.nix
    inputs.agenix.nixosModules.age
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  networking = {
    inherit hostName;
    firewall.allowedTCPPorts = [
      443
      80
    ];
  };
  nix = {
    gc.automatic = true;
    settings.experimental-features = [
      "flakes"
      "nix-command"
    ];
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  preservation = {
    enable = true;
    preserveAt."/persistent" = {
      directories = [
        "/var/lib/postgresql"
        "/var/lib/${app.runtimeUser}"
        {
          directory = "/etc/ssh";
          inInitrd = true;
        }
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
      ];
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];
    };
  };
  programs.bash.promptInit = "";
  security.sudo.wheelNeedsPassword = false;
  services = {
    adonisjs-app = lib.mkIf (app.framework == "adonisjs") {
      inherit (app) port;
      appUrl = "http://${hostName}";
      enable = true;
      environmentFile = config.age.secrets.secrets-env.path;
      extraEnvironment = { };
      host = "127.0.0.1";
      name = app.runtimeUser;
      nginx = {
        defaultVirtualHost = true;
        serverName = hostName;
      };
      package = inputs.self.packages.${pkgs.stdenv.system}.${app.packageAttrName};
    };
    django-app = lib.mkIf (app.framework == "django") {
      inherit (app) port;
      allowedHosts = [
        hostName
        "127.0.0.1"
        "localhost"
        "[::1]"
      ];
      appName = "Django Starter";
      csrfTrustedOrigins = [
        "http://${hostName}"
      ];
      enable = true;
      environmentFile = config.age.secrets.secrets-env.path;
      extraEnvironment = { };
      host = "127.0.0.1";
      name = app.runtimeUser;
      nginx = {
        defaultVirtualHost = true;
        serverName = hostName;
      };
      package = inputs.self.packages.${pkgs.stdenv.system}.${app.packageAttrName};
    };
    fastapi-postgres-app = lib.mkIf (app.framework == "fastapi-postgres") {
      inherit (app) port;
      allowedHosts = [
        hostName
        "127.0.0.1"
        "localhost"
        "[::1]"
      ];
      appName = "FastAPI Postgres Starter";
      enable = true;
      environmentFile = config.age.secrets.secrets-env.path;
      extraEnvironment = { };
      host = "127.0.0.1";
      name = app.runtimeUser;
      nginx = {
        defaultVirtualHost = true;
        serverName = hostName;
      };
      package = inputs.self.packages.${pkgs.stdenv.system}.${app.packageAttrName};
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    postgresql = {
      authentication = pkgs.lib.mkOverride 10 ''
        # type database user address method
        local all all trust
      '';
      enable = true;
    };
  };
  system.stateVersion = "25.11";
  systemd.suppressedSystemUnits = [
    "systemd-machine-id-commit.service"
  ];
  users = {
    allowNoPasswordLogin = true;
    mutableUsers = false;
    users = {
      nixos = {
        extraGroups = [
          "wheel"
        ];
        isNormalUser = true;
        openssh.authorizedKeys.keyFiles = opensshAuthorizedKeyFiles;
      };
      root.openssh.authorizedKeys.keyFiles = opensshAuthorizedKeyFiles;
    };
  };
  virtualisation.vmVariantWithDisko = {
    disko.devices.disk.main.content.partitions = {
      persistent.size = pkgs.lib.mkForce "1G";
      swap.size = pkgs.lib.mkForce "1M";
    };
    users.users.nixos.password = "password";
    virtualisation = {
      diskSize = 8 * 1024;
      graphics = false;
      memorySize = 4096;
    };
  };
}
