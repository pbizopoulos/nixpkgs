{
  inputs = {
    agenix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ryantm/agenix";
    };
    agenix-shell = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:aciceri/agenix-shell";
    };
    blueprint = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/blueprint";
    };
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    preservation.url = "github:nix-community/preservation";
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };
  };
  outputs =
    inputs:
    let
      blueprintOutputs = inputs.blueprint {
        inherit inputs;
      };
      checks = builtins.mapAttrs (
        _system: systemChecks:
        systemChecks
        // {
          "django-template" = systemChecks.django_template;
          "fastapi-postgres-template" = systemChecks.fastapi_postgres_template;
        }
      ) blueprintOutputs.checks;
      nixosConfigurations = blueprintOutputs.nixosConfigurations // {
        django_template = blueprintOutputs.nixosConfigurations."django-template";
        fastapi_postgres_template = blueprintOutputs.nixosConfigurations."fastapi-postgres-template";
      };
      packages = builtins.mapAttrs (
        _system: systemPackages:
        systemPackages
        // {
          "django-template" = systemPackages.django_template;
          "fastapi-postgres-template" = systemPackages.fastapi_postgres_template;
        }
      ) blueprintOutputs.packages;
    in
    blueprintOutputs
    // {
      inherit (inputs) blueprint;
      inherit
        checks
        nixosConfigurations
        packages
        ;
    };
}
