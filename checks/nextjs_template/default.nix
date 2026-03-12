{ inputs, pkgs, ... }:
pkgs.testers.runNixOSTest rec {
  name = builtins.baseNameOf ./.;
  nodes.machine = {
    environment.systemPackages = [ inputs.self.packages.${pkgs.stdenv.system}.${name} ];
  };
  testScript = ''
    machine.succeed("DEBUG=1 ${name} > /tmp/${name}.log 2>&1 & echo $! > /tmp/${name}.pid")
    machine.wait_until_succeeds("ss -tln | grep -q ':3000'", timeout=60)
    machine.succeed("kill $(cat /tmp/${name}.pid)")
  '';
}
