{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.supabase-cli
    pkgs.docker-compose
  ];
  virtualisation.docker.enable = true;
  # Placeholder for more complex Supabase setup
}
