{
  pkgs ? import <nixpkgs> { },
}:
let
  exit-codes = pkgs.python312Packages.buildPythonPackage rec {
    format = "wheel";
    pname = "exit_codes";
    propagatedBuildInputs = [ ];
    pythonImportsCheck = [
      pname
    ];
    src = pkgs.python312Packages.fetchPypi rec {
      inherit
        pname
        version
        format
        ;
      dist = python;
      python = "py2.py3";
      sha256 = "CURIRHcgQ/m+IhKIVgiHkr4Pkc2+Jpr5krEzilRk3IU=";
    };
    version = "1.3.0";
  };
in
pkgs.python312Packages.buildPythonPackage rec {
  format = "wheel";
  pname = "cosmic_ray";
  propagatedBuildInputs = [
    exit-codes
    pkgs.python312Packages.aiohttp
    pkgs.python312Packages.anybadge
    pkgs.python312Packages.click
    pkgs.python312Packages.decorator
    pkgs.python312Packages.gitpython
    pkgs.python312Packages.parso
    pkgs.python312Packages.rich
    pkgs.python312Packages.sqlalchemy
    pkgs.python312Packages.stevedore
    pkgs.python312Packages.toml
    pkgs.python312Packages.yattag
  ];
  pythonImportsCheck = [
    pname
  ];
  src = pkgs.python312Packages.fetchPypi rec {
    inherit
      pname
      version
      format
      ;
    dist = python;
    python = "py3";
    sha256 = "RIr35qo2W9uyVBBrkHpneVD8eF93RauaZZ1HNShbswc=";
  };
  version = "8.4.6";
}
