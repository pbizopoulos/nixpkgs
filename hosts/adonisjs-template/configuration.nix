{
  config,
  inputs,
  modulesPath,
  pkgs,
  ...
}:
let
  hostName = baseNameOf ./.;
  opensshAuthorizedKeyFiles = [
    ./../../prm/developer.pub
  ];
  packageAttrName = "adonisjs-template";
  packageName = "adonisjs-template";
in
{
  age.secrets.secrets-env = {
    file = ../../secrets/secrets.age;
    group = packageName;
    owner = packageName;
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
    adonisjs-app = {
      appUrl = "http://${hostName}";
      enable = true;
      environmentFile = config.age.secrets.secrets-env.path;
      extraEnvironment = { };
      host = "127.0.0.1";
      name = packageName;
      nginx = {
        defaultVirtualHost = true;
        serverName = hostName;
      };
      package = inputs.self.packages.${pkgs.stdenv.system}.${packageAttrName};
      port = 3333;
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
