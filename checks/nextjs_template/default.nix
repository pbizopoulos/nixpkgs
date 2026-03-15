{
  inputs,
  pkgs,
  ...
}:
pkgs.testers.runNixOSTest rec {
  name = builtins.baseNameOf ./.;
  nodes.machine = {
    environment.systemPackages = [
      inputs.self.packages.${pkgs.stdenv.system}.${name}
      pkgs.docker
      pkgs.git
    ];
    virtualisation = {
      cores = 4;
      diskSize = 32768;
      docker.enable = true;
      memorySize = 16384;
    };
  };
  testScript =
    let
      images = inputs.self.packages.${pkgs.stdenv.system}.supabase;
    in
    ''
      machine.wait_for_unit("docker.service")
      machine.succeed("for img in ${images}/*; do docker load -i $img; done")
      machine.succeed("DEBUG=1 ${name}")
    '';
}
