{ inputs, pkgs, ... }:
let
  mockSupabase = pkgs.writeShellScriptBin "supabase" ''
    echo "Mock supabase called with: $@"
    exit 0
  '';
  name = "fastapi_supabase_template";
  fastapi-mocked = inputs.self.packages.${pkgs.stdenv.system}.${name}.override {
    supabase-cli = mockSupabase;
  };
in
pkgs.testers.runNixOSTest {
  inherit name;
  nodes.machine = {
    environment.systemPackages = [
      mockSupabase
      fastapi-mocked
      pkgs.python3
    ];
    virtualisation.docker.enable = true;
  };
  testScript = ''
    machine.wait_for_unit("docker.service")
    machine.succeed("cp -r ${fastapi-mocked}/lib/${name} /tmp/${name}")
    machine.succeed("chmod -R +w /tmp/${name}")
    machine.succeed("cd /tmp/${name} && pytest tests/unit")
  '';
}
