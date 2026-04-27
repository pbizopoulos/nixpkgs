{
  inputs,
  pkgs,
  ...
}:
pkgs.testers.runNixOSTest rec {
  name = builtins.baseNameOf ./.;
  nodes.machine.environment.systemPackages = [
    inputs.self.packages.${pkgs.stdenv.system}.${name}
    pkgs.curl
  ];
  testScript = ''
    machine.succeed("${name} -p 8080 >/tmp/${name}.log 2>&1 &")
    machine.wait_until_succeeds("curl -fsS http://127.0.0.1:8080 | grep -F 'Hello World!'")
  '';
}
