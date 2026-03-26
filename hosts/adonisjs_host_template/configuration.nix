{
  config,
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
    inputs.agenix.nixosModules.age
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
      authentication = pkgs.lib.mkOverride 10 ''
        # type database user address method
        local all all trust
      '';
      enable = true;
    };
  };
  system.stateVersion = "25.11";
  systemd = {
    services.${packageName} = {
      after = [
        "network.target"
        "postgresql.service"
      ];
      serviceConfig = {
        EnvironmentFile = config.age.secrets.secrets-env.path;
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
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKN1+fP1Xy+m/V7/L9uC7N+o8Z2T8Y8+M1C1kS8mGz6f"
        ];
      };
      root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKN1+fP1Xy+m/V7/L9uC7N+o8Z2T8Y8+M1C1kS8mGz6f"
      ];
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
