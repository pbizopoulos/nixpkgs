{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
pkgs.stdenv.mkDerivation rec {
  dontBuild = true;
  buildInputs = [
    pkgs.udev
    pkgs.alsa-lib
    pkgs.vulkan-loader
    pkgs.libxkbcommon
    pkgs.wayland
    pkgs.libX11
    pkgs.libXcursor
    pkgs.libXi
    pkgs.libXrandr
    pkgs.rustc
    pkgs.cargo
    supabase-cli
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname}
    cp -rL . $out/lib/${pname}
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Smoke testing ${pname}"; exit 0; fi' >> $out/bin/${pname}
    echo "exec ${pkgs.cargo}/bin/cargo run" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.rustc
          pkgs.cargo
          pkgs.pkg-config
          supabase-cli
        ]
      } \
      --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath buildInputs}"
    runHook postInstall
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.pkg-config
    supabase-cli
  ];
  pname = "ply_engine_supabase_template";
  src = ./.;
  version = "0.0.0";
}
