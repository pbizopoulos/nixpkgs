{ inputs, pkgs, ... }:
pkgs.testers.runNixOSTest rec {
  name = baseNameOf ./.;
  nodes.machine.environment.systemPackages = [ inputs.self.packages.${pkgs.stdenv.system}.${name} ];
  testScript = ''
    machine.succeed("touch flake.nix")
    machine.succeed("mkdir -p packages/rust_template")
    machine.succeed("DEBUG=1 default test-repo")
  '';
}
