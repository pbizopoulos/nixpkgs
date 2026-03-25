let
  hostPubPath = ../prm/adonisjs_host_template.pub;
  system =
    if builtins.pathExists hostPubPath then
      builtins.readFile hostPubPath
    else
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKN1+fP1Xy+m/V7/L9uC7N+o8Z2T8Y8+M1C1kS8mGz6f";
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKN1+fP1Xy+m/V7/L9uC7N+o8Z2T8Y8+M1C1kS8mGz6f";
in
{
  "secrets.age".publicKeys = [
    system
    user
  ];
}
