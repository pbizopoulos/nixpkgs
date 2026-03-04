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
      toml-sort.enable = true;
      yamlfmt.enable = true;
    };
    projectRootFile = "flake.nix";
    settings = {
      formatter = {
        alphabetize-nix = {
          command = inputs.canonicalization.packages.${pkgs.stdenv.system}.alphabetize-nix;
          includes = [ "*.nix" ];
          priority = 0;
        };
        check_repository_directory_structure = {
          command =
            inputs.canonicalization.packages.${pkgs.stdenv.system}.check_repository_directory_structure;
          includes = [ "flake.nix" ];
          priority = 0;
        };
        remove_empty_lines = {
          command = inputs.canonicalization.packages.${pkgs.stdenv.system}.remove_empty_lines;
          includes = [ "*" ];
          priority = 0;
        };
        rustfmt.priority = 1;
        uncomment = {
          command = inputs.canonicalization.packages.${pkgs.stdenv.system}.uncomment;
          includes = [ "*" ];
        };
      };
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
