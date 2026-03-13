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
        excludes = [
          "**/app.css"
          "**/daisyui-theme.js"
          "**/daisyui.js"
          "**/topbar.js"
        ];
        formatUnsafe = true;
      };
      cabal-fmt.enable = true;
      clang-format.enable = true;
      cue.enable = true;
      dart-format.enable = true;
      deadnix.enable = true;
      deno.enable = true;
      dfmt.enable = true;
      dhall.enable = true;
      dos2unix.enable = true;
      elm-format.enable = true;
      erlfmt.enable = true;
      fantomas = {
        enable = true;
        excludes = [
          "*.ml"
        ];
      };
      fnlfmt.enable = true;
      fourmolu.enable = true;
      gleam.enable = true;
      gofmt.enable = true;
      gofumpt.enable = true;
      goimports.enable = true;
      google-java-format.enable = true;
      hlint.enable = true;
      jsonfmt = {
        enable = true;
        excludes = [
          "**/tsconfig.json"
        ];
      };
      jsonnet-lint.enable = true;
      jsonnetfmt.enable = true;
      mdformat.enable = true;
      mdsh.enable = true;
      mix-format.enable = true;
      nimpretty.enable = true;
      nixfmt.enable = true;
      ocamlformat.enable = true;
      odinfmt.enable = true;
      ormolu.enable = true;
      oxipng.enable = true;
      php-cs-fixer.enable = true;
      prettier.enable = true;
      ruff-check = {
        enable = true;
        extendSelect = [
          "ALL"
        ];
      };
      ruff-format.enable = true;
      rufo.enable = true;
      rustfmt.enable = true;
      scalafmt.enable = true;
      shellcheck.enable = true;
      shfmt = {
        enable = true;
        simplify = true;
      };
      statix.enable = true;
      stylish-haskell.enable = true;
      stylua.enable = true;
      swift-format.enable = true;
      taplo.enable = true;
      texfmt.enable = true;
      toml-sort.enable = true;
      yamlfmt.enable = true;
      yamllint.enable = true;
      zig.enable = true;
    };
    projectRootFile = "flake.nix";
    settings = {
      formatter = {
        bibtex-tidy = {
          command = pkgs.bibtex-tidy;
          includes = [
            "*.bib"
          ];
          options = [
            "--duplicates"
            "--no-align"
            "--no-wrap"
            "--sort"
            "--sort-fields"
            "--v2"
          ];
        };
        biome.options = [
          "--max-diagnostics=none"
        ];
        check_repository_directory_structure = {
          command = inputs.self.packages.${pkgs.stdenv.system}.check_repository_directory_structure;
          includes = [
            "flake.nix"
          ];
          priority = 0;
        };
        crystal = {
          command = "${pkgs.crystal}/bin/crystal";
          includes = [
            "*.cr"
          ];
          options = [
            "tool"
            "format"
          ];
        };
        kdlfmt = {
          command = "${pkgs.kdlfmt}/bin/kdlfmt";
          includes = [
            "*.kdl"
          ];
          options = [
            "format"
          ];
        };
        ktlint = {
          command = "${pkgs.ktlint}/bin/ktlint";
          includes = [
            "*.kt"
          ];
          options = [
            "-F"
          ];
        };
        mypy = {
          command = pkgs.mypy;
          includes = [
            "*.py"
          ];
          options = [
            "--cache-dir=/tmp/.mypy_cache"
            "--explicit-package-bases"
            "--ignore-missing-imports"
            "--strict"
          ];
        };
        nix-alphabetize = {
          command = inputs.self.packages.${pkgs.stdenv.system}.nix-alphabetize;
          includes = [
            "*.nix"
          ];
          priority = 0;
        };
        php-cs-fixer.options = [
          "--allow-risky=yes"
        ];
        prettier.options = [
          "--max-diagnostics=none"
        ];
        remove_empty_lines = {
          command = inputs.self.packages.${pkgs.stdenv.system}.remove_empty_lines;
          includes = [
            "*"
          ];
          priority = 0;
        };
        ruff-check.options = [
          "--cache-dir=/tmp/.ruff_cache"
          "--unsafe-fixes"
        ];
        ruff-format.options = [
          "--cache-dir=/tmp/.ruff_cache"
        ];
        rustfmt.priority = 1;
        shfmt.options = [
          "--posix"
        ];
        ssort = {
          command = pkgs.python3Packages.ssort;
          includes = [
            "*.py"
          ];
          priority = 1;
        };
        uncomment = {
          command = inputs.self.packages.${pkgs.stdenv.system}.uncomment;
          includes = [
            "*"
          ];
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
