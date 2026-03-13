{
  pkgs,
  ...
}:
{
  boot.loader.grub.enable = false;
  environment.systemPackages = [
    pkgs.docker-compose
    pkgs.supabase-cli
  ];
  fileSystems."/".device = "/dev/null";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.05";
  virtualisation.docker.enable = true;
}
