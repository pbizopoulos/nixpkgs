{ inputs, pkgs, ... }:
pkgs.testers.runNixOSTest rec {
  name = builtins.baseNameOf ./.;
  nodes.machine = {
    environment.systemPackages = [ inputs.self.packages.${pkgs.stdenv.system}.${pname} ];
  };
  testScript = ''
    machine.succeed("set +e; DEBUG=1 ${pname} > /tmp/${pname}.log 2>&1; status=$?; cat /tmp/${pname}.log; exit $status")
  '';
}
