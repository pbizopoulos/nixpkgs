{ inputs, pkgs, ... }:
let
  mockSupabase = pkgs.writeShellScriptBin "supabase" ''
    echo "Mock supabase called with: $@"
    exit 0
  '';
  name = "foundry_supabase_template";
  foundry-mocked = inputs.self.packages.${pkgs.stdenv.system}.${name}.override {
    supabase-cli = mockSupabase;
  };
in
pkgs.testers.runNixOSTest {
  inherit name;
  nodes.machine = {
    environment.systemPackages = [
      mockSupabase
      foundry-mocked
      pkgs.foundry-bin
    ];
    virtualisation.docker.enable = true;
  };
  testScript = ''
    machine.wait_for_unit("docker.service")
    machine.succeed("cp -r ${foundry-mocked}/lib/${name} /tmp/${name}")
    machine.succeed("chmod -R +w /tmp/${name}")
    # machine.succeed("cd /tmp/${name} && forge test")
  '';
}
