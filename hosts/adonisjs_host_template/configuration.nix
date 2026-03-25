{
  inputs,
  modulesPath,
  pkgs,
  ...
}:
let
  hostName = baseNameOf ./.;
  packageName = "adonisjs_template";
in
{
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
            size = "20G";
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
  environment.systemPackages = [
    inputs.self.packages.${pkgs.stdenv.system}.${packageName}
  ];
  fileSystems."/persistent".neededForBoot = true;
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  networking = {
    inherit hostName;
    firewall.allowedTCPPorts = [
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
        "/var/lib/${packageName}"
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
    nginx = {
      enable = true;
      virtualHosts.${hostName} = {
        default = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3333";
          recommendedProxySettings = true;
        };
      };
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    postgresql = {
      enable = true;
      ensureDatabases = [
        packageName
      ];
      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = packageName;
        }
      ];
    };
  };
  system.stateVersion = "25.11";
  systemd = {
    services.${packageName} = {
      after = [
        "network.target"
        "postgresql.service"
      ];
      environment = {
        APP_KEY = "01234567890123456789012345678901";
        APP_NAME = "AdonisJS Starter";
        APP_URL = "http://127.0.0.1:3333";
        DB_DATABASE = packageName;
        DB_HOST = "/run/postgresql";
        DB_PASSWORD = "unused";
        DB_PORT = "5432";
        DB_SSL = "false";
        DB_USER = packageName;
        HOST = "127.0.0.1";
        LOG_LEVEL = "info";
        NODE_ENV = "production";
        PORT = "3333";
        TZ = "UTC";
      };
      serviceConfig = {
        ExecStart = "${inputs.self.packages.${pkgs.stdenv.system}.${packageName}}/bin/${packageName}";
        Group = packageName;
        Restart = "always";
        RestartSec = 5;
        StateDirectory = packageName;
        User = packageName;
      };
      wantedBy = [
        "multi-user.target"
      ];
    };
    suppressedSystemUnits = [
      "systemd-machine-id-commit.service"
    ];
  };
  users = {
    allowNoPasswordLogin = true;
    groups.${packageName} = { };
    mutableUsers = false;
    users = {
      ${packageName} = {
        group = packageName;
        home = "/var/lib/${packageName}";
        isSystemUser = true;
      };
      nixos = {
        extraGroups = [
          "wheel"
        ];
        isNormalUser = true;
      };
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
