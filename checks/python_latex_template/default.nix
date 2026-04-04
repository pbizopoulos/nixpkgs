{
  inputs,
  pkgs,
  ...
}:
pkgs.testers.runNixOSTest rec {
  name = "python_latex_template";
  nodes.machine.environment.systemPackages = [
    inputs.self.packages.${pkgs.stdenv.system}.${name}
  ];
  testScript = ''
    machine.succeed("DEBUG=1 ${name}")
  '';
}
