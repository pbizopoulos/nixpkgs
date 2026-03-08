{ pkgs, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  environment.systemPackages = [
    pkgs.supabase-cli
    pkgs.docker-compose
  ];
  virtualisation.docker.enable = true;
  system.stateVersion = "26.05";
  boot.loader.grub.enable = false;
  fileSystems."/" = {
    device = "/dev/null";
  };
}
