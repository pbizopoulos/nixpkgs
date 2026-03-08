{ inputs, pkgs, ... }:
let
  mockSupabase = pkgs.writeShellScriptBin "supabase" ''
    echo "Mock supabase called with: $@"
    exit 0
  '';
  name = "qwik_supabase_template";
  qwik-mocked = inputs.self.packages.${pkgs.stdenv.system}.${name}.override {
    supabase-cli = mockSupabase;
  };
in
pkgs.testers.runNixOSTest {
  inherit name;
  nodes.machine = {
    environment.systemPackages = [
      mockSupabase
      qwik-mocked
      pkgs.nodejs
    ];
    virtualisation.docker.enable = true;
  };
  testScript = ''
    machine.wait_for_unit("docker.service")
    machine.succeed("cp -r ${qwik-mocked}/lib/node_modules/${name} /tmp/${name}")
    machine.succeed("chmod -R +w /tmp/${name}")
    machine.succeed("cd /tmp/${name} && DEBUG=1 PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers} npm run test:unit")
  '';
}
