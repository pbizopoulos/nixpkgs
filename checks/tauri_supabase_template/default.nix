{ inputs, pkgs, ... }:
let
  mockSupabase = pkgs.writeShellScriptBin "supabase" ''
    echo "Mock supabase called with: $@"
    exit 0
  '';
  name = "tauri_supabase_template";
  tauri-mocked = inputs.self.packages.${pkgs.stdenv.system}.${name}.override {
    supabase-cli = mockSupabase;
  };
in
pkgs.testers.runNixOSTest {
  inherit name;
  nodes.machine = {
    environment.systemPackages = [
      mockSupabase
      tauri-mocked
      pkgs.nodejs
      pkgs.rustc
      pkgs.cargo
    ];
    virtualisation.docker.enable = true;
  };
  testScript = ''
    machine.wait_for_unit("docker.service")
    machine.succeed("cp -r ${tauri-mocked}/lib/node_modules/${name} /tmp/${name}")
    machine.succeed("chmod -R +w /tmp/${name}")
    # machine.succeed("cd /tmp/${name} && npm run test:unit")
  '';
}
