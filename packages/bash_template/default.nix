{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
  ];
  installPhase = ''
    mkdir -p $out/bin
    cp main.sh $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} --prefix PATH : ${pkgs.bash}/bin
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
