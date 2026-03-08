{ inputs, pkgs, ... }:
let
  mockSupabase = pkgs.writeShellScriptBin "supabase" ''
    echo "Mock supabase called with: $@"
    exit 0
  '';
  name = "react_native_supabase_template";
  react-native-mocked = inputs.self.packages.${pkgs.stdenv.system}.${name}.override {
    supabase-cli = mockSupabase;
  };
in
pkgs.testers.runNixOSTest {
  inherit name;
  nodes.machine = {
    environment.systemPackages = [
      mockSupabase
      react-native-mocked
      pkgs.nodejs
    ];
    virtualisation.docker.enable = true;
  };
  testScript = ''
    machine.wait_for_unit("docker.service")
    machine.succeed("cp -r ${react-native-mocked}/lib/node_modules/${name} /tmp/${name}")
    machine.succeed("chmod -R +w /tmp/${name}")
    # machine.succeed("cd /tmp/${name} && npm run test:unit")
  '';
}
