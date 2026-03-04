{
  flake,
  inputs,
  pkgs,
  ...
}:
let
  formatter = treefmtEval.config.build.wrapper;
  treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
    programs = {
      actionlint.enable = true;
      deadnix.enable = true;
      nixfmt = {
        enable = true;
        strict = true;
      };
      rustfmt.enable = true;
      statix.enable = true;
      yamlfmt.enable = true;
    };
    projectRootFile = "flake.nix";
    settings = {
      global.excludes = [
        "*/prm/**"
        "*/tmp/**"
      ];
    };
  };
in
formatter
// {
  passthru = formatter.passthru // {
    tests.check = treefmtEval.config.build.check flake;
  };
}
