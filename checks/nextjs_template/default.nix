{ inputs, pkgs, ... }:
let
  pname = baseNameOf ./.;
in
pkgs.testers.runNixOSTest rec {
  name = pname;
  nodes.machine = {
    environment.systemPackages = [ inputs.self.packages.${pkgs.stdenv.system}.${pname} ];
  };
  testScript = ''
    machine.succeed("set +e; ${pname} > /tmp/${pname}.log 2>&1; status=$?; cat /tmp/${pname}.log; exit $status")
  '';
}
