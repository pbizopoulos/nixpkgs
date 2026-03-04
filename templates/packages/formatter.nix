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
      beautysh.enable = true;
      biome = {
        enable = true;
        formatUnsafe = true;
      };
      clang-format.enable = true;
      deadnix.enable = true;
      hlint.enable = true;
      nixfmt = {
        enable = true;
        strict = true;
      };
      ormolu.enable = true;
      prettier.enable = true;
      ruff-check = {
        enable = true;
        extendSelect = [ "ALL" ];
      };
      ruff-format.enable = true;
      rustfmt.enable = true;
      shellcheck.enable = true;
      shfmt = {
        enable = true;
        simplify = true;
      };
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
        alphabetize_python = {
          command = inputs.canonicalization.packages.${pkgs.stdenv.system}.alphabetize_python;
          includes = [ "*.py" ];
          priority = 0;
        };
        biome.options = [ "--max-diagnostics=none" ];
        check_repository_directory_structure = {
          command =
            inputs.canonicalization.packages.${pkgs.stdenv.system}.check_repository_directory_structure;
          includes = [ "flake.nix" ];
          priority = 0;
        };
        mypy = {
          command = pkgs.mypy;
          includes = [ "*.py" ];
          options = [
            "--cache-dir=/tmp/.mypy_cache"
            "--explicit-package-bases"
            "--ignore-missing-imports"
            "--strict"
          ];
        };
        remove_empty_lines = {
          command = inputs.canonicalization.packages.${pkgs.stdenv.system}.remove_empty_lines;
          includes = [ "*" ];
          priority = 0;
        };
        ruff-check.options = [
          "--cache-dir=/tmp/.ruff_cache"
          "--unsafe-fixes"
        ];
        ruff-format.options = [ "--cache-dir=/tmp/.ruff_cache" ];
        rustfmt.priority = 1;
        shfmt.options = [ "--posix" ];
        ssort = {
          command = pkgs.python3Packages.ssort;
          includes = [ "*.py" ];
          priority = 1;
        };
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
