{ inputs, pkgs, ... }:
let
  mockSupabase = pkgs.writeShellScriptBin "supabase" ''
    echo "Mock supabase called with: $@"
    exit 0
  '';
  name = "ply_engine_supabase_template";
  ply-engine-mocked = inputs.self.packages.${pkgs.stdenv.system}.${name}.override {
    supabase-cli = mockSupabase;
  };
in
pkgs.testers.runNixOSTest {
  inherit name;
  nodes.machine = {
    environment.systemPackages = [
      mockSupabase
      ply-engine-mocked
      pkgs.rustc
      pkgs.cargo
    ];
    virtualisation.docker.enable = true;
  };
  testScript = ''
    machine.wait_for_unit("docker.service")
    machine.succeed("cp -r ${ply-engine-mocked}/lib/${name} /tmp/${name}")
    machine.succeed("chmod -R +w /tmp/${name}")
    # machine.succeed("cd /tmp/${name} && cargo test")
  '';
}
