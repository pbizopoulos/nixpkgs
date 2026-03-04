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
      cljfmt.enable = true;
      cue.enable = true;
      dart-format.enable = true;
      deadnix.enable = true;
      dfmt.enable = true;
      dhall.enable = true;
      elm-format.enable = true;
      erlfmt.enable = true;
      fantomas.enable = true;
      fnlfmt.enable = true;
      gleam.enable = true;
      gofmt.enable = true;
      google-java-format.enable = true;
      hlint.enable = true;
      jsonnet-lint.enable = true;
      jsonnetfmt.enable = true;
      mdformat.enable = true;
      mdsh.enable = true;
      mix-format.enable = true;
      nimpretty.enable = true;
      nixf-diagnose.enable = true;
      nixfmt = {
        enable = true;
        strict = true;
      };
      ocamlformat.enable = true;
      odinfmt.enable = false;
      ormolu.enable = true;
      perltidy.enable = true;
      prettier.enable = true;
      ruff-check = {
        enable = true;
        extendSelect = [ "ALL" ];
      };
      ruff-format.enable = true;
      rufo.enable = true;
      rustfmt.enable = true;
      shellcheck.enable = true;
      shfmt = {
        enable = true;
        simplify = true;
      };
      statix.enable = true;
      stylish-haskell.enable = true;
      stylua.enable = true;
      texfmt.enable = true;
      toml-sort.enable = true;
      yamlfmt.enable = true;
      zig.enable = true;
    };
    projectRootFile = "flake.nix";
    settings = {
      formatter = {
        bibtex-tidy = {
          command = pkgs.bibtex-tidy;
          includes = [ "*.bib" ];
          options = [
            "--duplicates"
            "--no-align"
            "--no-wrap"
            "--sort"
            "--sort-fields"
            "--v2"
          ];
        };
        biome.options = [ "--max-diagnostics=none" ];
        check_repository_directory_structure = {
          command = inputs.self.packages.${pkgs.stdenv.system}.check_repository_directory_structure;
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
        nix-alphabetize = {
          command = inputs.self.packages.${pkgs.stdenv.system}.nix-alphabetize;
          includes = [ "*.nix" ];
          priority = 0;
        };
        python_alphabetize = {
          command = inputs.self.packages.${pkgs.stdenv.system}.python_alphabetize;
          includes = [ "*.py" ];
          priority = 0;
        };
        remove_empty_lines = {
          command = inputs.self.packages.${pkgs.stdenv.system}.remove_empty_lines;
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
        texfmt.options = [ "--nowrap" ];
        uncomment = {
          command = inputs.self.packages.${pkgs.stdenv.system}.uncomment;
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
