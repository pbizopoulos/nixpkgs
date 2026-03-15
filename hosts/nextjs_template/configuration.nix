{
  config,
  inputs,
  pkgs,
  ...
}:
let
  hostName = baseNameOf ./.;
in
{
  age.secrets.secrets-env = {
    file = ../../secrets/secrets.age;
    group = hostName;
    owner = hostName;
  };
  boot = {
    initrd.systemd.enable = true;
    loader.grub = {
      device = "/dev/sda";
      enable = true;
    };
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
            size = "10G";
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
    inputs.agenix.packages.${pkgs.stdenv.system}.default
    pkgs.docker-compose
    pkgs.supabase-cli
  ];
  fileSystems."/persistent".neededForBoot = true;
  imports = [
    inputs.agenix.nixosModules.age
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
  ];
  networking = {
    inherit hostName;
    firewall.allowedTCPPorts = [
      3000
      80
    ];
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  preservation = {
    enable = true;
    preserveAt."/persistent" = {
      directories = [
        "/var/lib/containers/storage"
        {
          directory = "/etc/ssh";
          inInitrd = true;
        }
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        {
          directory = "/var/lib/${hostName}";
          group = hostName;
          mode = "0700";
          user = hostName;
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
  services = {
    nginx = {
      enable = true;
      virtualHosts."localhost".locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        recommendedProxySettings = true;
      };
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
    };
  };
  system.stateVersion = "26.05";
  systemd.services = {
    ${hostName} = {
      after = [
        "network.target"
      ];
      description = "Next.js Template Service";
      serviceConfig = {
        EnvironmentFile = config.age.secrets.secrets-env.path;
        ExecStart = "${inputs.self.packages.${pkgs.stdenv.system}.${hostName}}/bin/nextjs_template";
        Group = hostName;
        Restart = "always";
        User = hostName;
        WorkingDirectory = "/var/lib/${hostName}";
      };
      wantedBy = [
        "multi-user.target"
      ];
    };
    load-supabase-images = {
      after = [
        "docker.service"
      ];
      description = "Load Supabase Docker Images";
      script = ''
        for img in ${inputs.self.packages.${pkgs.stdenv.system}.supabase}/*.tar; do
          ${pkgs.docker}/bin/docker load -i "$img"
        done
      '';
      wantedBy = [
        "multi-user.target"
      ];
    };
  };
  users = {
    groups.${hostName} = { };
    users.${hostName} = {
      createHome = true;
      group = hostName;
      home = "/var/lib/${hostName}";
      isSystemUser = true;
    };
  };
  virtualisation = {
    docker.enable = true;
    vmVariant = {
      disko.devices.disk.main.content.partitions.persistent.size = pkgs.lib.mkForce "1G";
      services.openssh.settings.PasswordAuthentication = pkgs.lib.mkForce true;
      users.users.${hostName}.password = hostName;
      virtualisation = {
        graphics = false;
        memorySize = 2048;
      };
    };
  };
}
