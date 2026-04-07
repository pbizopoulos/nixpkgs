{
  lib,
  ...
}:
{
  imports = [
    ../template/configuration.nix
  ];
  services.template-app.backend = lib.mkForce "django";
}
