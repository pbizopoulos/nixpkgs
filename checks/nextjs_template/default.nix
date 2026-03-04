{ inputs, pkgs, ... }:
let
  mockSupabase = pkgs.writeShellScriptBin "supabase" ''
    echo "Mock supabase called with: $@"
    exit 0
  '';
  nextjs-mocked = inputs.self.packages.${pkgs.stdenv.system}.nextjs_template.override {
    supabase-cli = mockSupabase;
  };
in
pkgs.testers.runNixOSTest rec {
  name = baseNameOf ./.;
  nodes.machine = {
    environment.systemPackages = [
      mockSupabase
      nextjs-mocked
      pkgs.nodejs
    ];
    virtualisation.docker.enable = true;
  };
  testScript = ''
    machine.wait_for_unit("docker.service")
    machine.succeed("cp -r ${nextjs-mocked}/lib/node_modules/${name} /tmp/${name}")
    machine.succeed("chmod -R +w /tmp/${name}")
    machine.succeed("cd /tmp/${name} && PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers} npm run test:unit")
  '';
}
