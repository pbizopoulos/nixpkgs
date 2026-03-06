{ pkgs ? import <nixpkgs> { }
,
}:
let
  inherit (pkgs) lib;
  beamPackages = pkgs.beam.packages.erlang_27;
  inherit (beamPackages) elixir;
  pname = "phoenix_template";
  version = "0.1.0";
  src = ./.;
in
pkgs.stdenv.mkDerivation rec {
  inherit pname version src;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [
    elixir
    pkgs.postgresql
    pkgs.nodejs
  ];
  installPhase = ''
        mkdir -p $out/lib/${pname}
        cp -r . $out/lib/${pname}
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    export LC_ALL=C.UTF-8
    export ELIXIR_ERL_OPTIONS="+fnu"
    export MIX_HOME=\$HOME/.mix
    export HEX_HOME=\$HOME/.hex
    export PATH=\$PATH:${
      lib.makeBinPath [
        elixir
        pkgs.postgresql
        pkgs.nodejs
      ]
    }
    cd $out/lib/${pname}/src/phoenix_app
    if [ "\$DEBUG" == "1" ]; then
      # Try to run tests if possible, but Phoenix needs a running Postgres
      # In NixOS tests this will work because we provide Postgres
      mix deps.get --only test
      mix ecto.create --quiet
      mix ecto.migrate --quiet
      mix test
    else
      # Generic FizzBuzz for Phoenix template
      # We use elixir to run the main function we added
      mix run -e "PhoenixApp.main([])"
    fi
    EOF
        chmod +x $out/bin/${pname}
  '';
  meta.mainProgram = pname;
}
