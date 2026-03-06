{ lib
, beamPackages
, overrides ? (_x: _y: { })
,
}:
let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  self = packages // (overrides self packages);
  packages =
    with beamPackages;
    with self;
    {
      bandit = buildMix rec {
        name = "bandit";
        version = "1.10.3";
        src = fetchHex {
          pkg = "bandit";
          version = "${version}";
          sha256 = "99a52d909c48db65ca598e1962797659e3c0f1d06e825a50c3d75b74a5e2db18";
        };
        beamDeps = [
          hpax
          plug
          telemetry
          thousand_island
          websock
        ];
      };
      db_connection = buildMix rec {
        name = "db_connection";
        version = "2.9.0";
        src = fetchHex {
          pkg = "db_connection";
          version = "${version}";
          sha256 = "17d502eacaf61829db98facf6f20808ed33da6ccf495354a41e64fe42f9c509c";
        };
        beamDeps = [ telemetry ];
      };
      decimal = buildMix rec {
        name = "decimal";
        version = "2.3.0";
        src = fetchHex {
          pkg = "decimal";
          version = "${version}";
          sha256 = "a4d66355cb29cb47c3cf30e71329e58361cfcb37c34235ef3bf1d7bf3773aeac";
        };
        beamDeps = [ ];
      };
      dns_cluster = buildMix rec {
        name = "dns_cluster";
        version = "0.2.0";
        src = fetchHex {
          pkg = "dns_cluster";
          version = "${version}";
          sha256 = "ba6f1893411c69c01b9e8e8f772062535a4cf70f3f35bcc964a324078d8c8240";
        };
        beamDeps = [ ];
      };
      ecto = buildMix rec {
        name = "ecto";
        version = "3.13.5";
        src = fetchHex {
          pkg = "ecto";
          version = "${version}";
          sha256 = "df9efebf70cf94142739ba357499661ef5dbb559ef902b68ea1f3c1fabce36de";
        };
        beamDeps = [
          decimal
          jason
          telemetry
        ];
      };
      ecto_sql = buildMix rec {
        name = "ecto_sql";
        version = "3.13.5";
        src = fetchHex {
          pkg = "ecto_sql";
          version = "${version}";
          sha256 = "aa36751f4e6a2b56ae79efb0e088042e010ff4935fc8684e74c23b1f49e25fdc";
        };
        beamDeps = [
          db_connection
          ecto
          postgrex
          telemetry
        ];
      };
      esbuild = buildMix rec {
        name = "esbuild";
        version = "0.10.0";
        src = fetchHex {
          pkg = "esbuild";
          version = "${version}";
          sha256 = "468489cda427b974a7cc9f03ace55368a83e1a7be12fba7e30969af78e5f8c70";
        };
        beamDeps = [ jason ];
      };
      expo = buildMix rec {
        name = "expo";
        version = "1.1.1";
        src = fetchHex {
          pkg = "expo";
          version = "${version}";
          sha256 = "5fb308b9cb359ae200b7e23d37c76978673aa1b06e2b3075d814ce12c5811640";
        };
        beamDeps = [ ];
      };
      file_system = buildMix rec {
        name = "file_system";
        version = "1.1.1";
        src = fetchHex {
          pkg = "file_system";
          version = "${version}";
          sha256 = "7a15ff97dfe526aeefb090a7a9d3d03aa907e100e262a0f8f7746b78f8f87a5d";
        };
        beamDeps = [ ];
      };
      finch = buildMix rec {
        name = "finch";
        version = "0.21.0";
        src = fetchHex {
          pkg = "finch";
          version = "${version}";
          sha256 = "87dc6e169794cb2570f75841a19da99cfde834249568f2a5b121b809588a4377";
        };
        beamDeps = [
          mime
          mint
          nimble_options
          nimble_pool
          telemetry
        ];
      };
      gettext = buildMix rec {
        name = "gettext";
        version = "1.0.2";
        src = fetchHex {
          pkg = "gettext";
          version = "${version}";
          sha256 = "eab805501886802071ad290714515c8c4a17196ea76e5afc9d06ca85fb1bfeb3";
        };
        beamDeps = [ expo ];
      };
      hpax = buildMix rec {
        name = "hpax";
        version = "1.0.3";
        src = fetchHex {
          pkg = "hpax";
          version = "${version}";
          sha256 = "8eab6e1cfa8d5918c2ce4ba43588e894af35dbd8e91e6e55c817bca5847df34a";
        };
        beamDeps = [ ];
      };
      idna = buildRebar3 rec {
        name = "idna";
        version = "6.1.1";
        src = fetchHex {
          pkg = "idna";
          version = "${version}";
          sha256 = "92376eb7894412ed19ac475e4a86f7b413c1b9fbb5bd16dccd57934157944cea";
        };
        beamDeps = [ unicode_util_compat ];
      };
      jason = buildMix rec {
        name = "jason";
        version = "1.4.4";
        src = fetchHex {
          pkg = "jason";
          version = "${version}";
          sha256 = "c5eb0cab91f094599f94d55bc63409236a8ec69a21a67814529e8d5f6cc90b3b";
        };
        beamDeps = [ decimal ];
      };
      mime = buildMix rec {
        name = "mime";
        version = "2.0.7";
        src = fetchHex {
          pkg = "mime";
          version = "${version}";
          sha256 = "6171188e399ee16023ffc5b76ce445eb6d9672e2e241d2df6050f3c771e80ccd";
        };
        beamDeps = [ ];
      };
      mint = buildMix rec {
        name = "mint";
        version = "1.7.1";
        src = fetchHex {
          pkg = "mint";
          version = "${version}";
          sha256 = "fceba0a4d0f24301ddee3024ae116df1c3f4bb7a563a731f45fdfeb9d39a231b";
        };
        beamDeps = [ hpax ];
      };
      nimble_options = buildMix rec {
        name = "nimble_options";
        version = "1.1.1";
        src = fetchHex {
          pkg = "nimble_options";
          version = "${version}";
          sha256 = "821b2470ca9442c4b6984882fe9bb0389371b8ddec4d45a9504f00a66f650b44";
        };
        beamDeps = [ ];
      };
      nimble_pool = buildMix rec {
        name = "nimble_pool";
        version = "1.1.0";
        src = fetchHex {
          pkg = "nimble_pool";
          version = "${version}";
          sha256 = "af2e4e6b34197db81f7aad230c1118eac993acc0dae6bc83bac0126d4ae0813a";
        };
        beamDeps = [ ];
      };
      phoenix = buildMix rec {
        name = "phoenix";
        version = "1.8.5";
        src = fetchHex {
          pkg = "phoenix";
          version = "${version}";
          sha256 = "83b2bb125127e02e9f475c8e3e92736325b5b01b0b9b05407bcb4083b7a32485";
        };
        beamDeps = [
          bandit
          jason
          phoenix_pubsub
          phoenix_template
          plug
          plug_crypto
          telemetry
          websock_adapter
        ];
      };
      phoenix_ecto = buildMix rec {
        name = "phoenix_ecto";
        version = "4.7.0";
        src = fetchHex {
          pkg = "phoenix_ecto";
          version = "${version}";
          sha256 = "1d75011e4254cb4ddf823e81823a9629559a1be93b4321a6a5f11a5306fbf4cc";
        };
        beamDeps = [
          ecto
          phoenix_html
          plug
          postgrex
        ];
      };
      phoenix_html = buildMix rec {
        name = "phoenix_html";
        version = "4.3.0";
        src = fetchHex {
          pkg = "phoenix_html";
          version = "${version}";
          sha256 = "3eaa290a78bab0f075f791a46a981bbe769d94bc776869f4f3063a14f30497ad";
        };
        beamDeps = [ ];
      };
      phoenix_live_dashboard = buildMix rec {
        name = "phoenix_live_dashboard";
        version = "0.8.7";
        src = fetchHex {
          pkg = "phoenix_live_dashboard";
          version = "${version}";
          sha256 = "3a8625cab39ec261d48a13b7468dc619c0ede099601b084e343968309bd4d7d7";
        };
        beamDeps = [
          ecto
          mime
          phoenix_live_view
          telemetry_metrics
        ];
      };
      phoenix_live_reload = buildMix rec {
        name = "phoenix_live_reload";
        version = "1.6.2";
        src = fetchHex {
          pkg = "phoenix_live_reload";
          version = "${version}";
          sha256 = "d1f89c18114c50d394721365ffb428cce24f1c13de0467ffa773e2ff4a30d5b9";
        };
        beamDeps = [
          file_system
          phoenix
        ];
      };
      phoenix_live_view = buildMix rec {
        name = "phoenix_live_view";
        version = "1.1.26";
        src = fetchHex {
          pkg = "phoenix_live_view";
          version = "${version}";
          sha256 = "0ec34b24c69aa70c4f25a8901effe3462bee6c8ca80a9a4a7685215e3a0ac34e";
        };
        beamDeps = [
          jason
          phoenix
          phoenix_html
          phoenix_template
          plug
          telemetry
        ];
      };
      phoenix_pubsub = buildMix rec {
        name = "phoenix_pubsub";
        version = "2.2.0";
        src = fetchHex {
          pkg = "phoenix_pubsub";
          version = "${version}";
          sha256 = "adc313a5bf7136039f63cfd9668fde73bba0765e0614cba80c06ac9460ff3e96";
        };
        beamDeps = [ ];
      };
      phoenix_template = buildMix rec {
        name = "phoenix_template";
        version = "1.0.4";
        src = fetchHex {
          pkg = "phoenix_template";
          version = "${version}";
          sha256 = "2c0c81f0e5c6753faf5cca2f229c9709919aba34fab866d3bc05060c9c444206";
        };
        beamDeps = [ phoenix_html ];
      };
      plug = buildMix rec {
        name = "plug";
        version = "1.19.1";
        src = fetchHex {
          pkg = "plug";
          version = "${version}";
          sha256 = "560a0017a8f6d5d30146916862aaf9300b7280063651dd7e532b8be168511e62";
        };
        beamDeps = [
          mime
          plug_crypto
          telemetry
        ];
      };
      plug_crypto = buildMix rec {
        name = "plug_crypto";
        version = "2.1.1";
        src = fetchHex {
          pkg = "plug_crypto";
          version = "${version}";
          sha256 = "6470bce6ffe41c8bd497612ffde1a7e4af67f36a15eea5f921af71cf3e11247c";
        };
        beamDeps = [ ];
      };
      postgrex = buildMix rec {
        name = "postgrex";
        version = "0.22.0";
        src = fetchHex {
          pkg = "postgrex";
          version = "${version}";
          sha256 = "a68c4261e299597909e03e6f8ff5a13876f5caadaddd0d23af0d0a61afcc5d84";
        };
        beamDeps = [
          db_connection
          decimal
          jason
        ];
      };
      req = buildMix rec {
        name = "req";
        version = "0.5.17";
        src = fetchHex {
          pkg = "req";
          version = "${version}";
          sha256 = "0b8bc6ffdfebbc07968e59d3ff96d52f2202d0536f10fef4dc11dc02a2a43e39";
        };
        beamDeps = [
          finch
          jason
          mime
          plug
        ];
      };
      swoosh = buildMix rec {
        name = "swoosh";
        version = "1.23.0";
        src = fetchHex {
          pkg = "swoosh";
          version = "${version}";
          sha256 = "97aaf04481ce8a351e2d15a3907778bdf3b1ea071cfff3eb8728b65943c77f6d";
        };
        beamDeps = [
          bandit
          finch
          idna
          jason
          mime
          plug
          req
          telemetry
        ];
      };
      tailwind = buildMix rec {
        name = "tailwind";
        version = "0.4.1";
        src = fetchHex {
          pkg = "tailwind";
          version = "${version}";
          sha256 = "6249d4f9819052911120dbdbe9e532e6bd64ea23476056adb7f730aa25c220d1";
        };
        beamDeps = [ ];
      };
      telemetry = buildRebar3 rec {
        name = "telemetry";
        version = "1.3.0";
        src = fetchHex {
          pkg = "telemetry";
          version = "${version}";
          sha256 = "7015fc8919dbe63764f4b4b87a95b7c0996bd539e0d499be6ec9d7f3875b79e6";
        };
        beamDeps = [ ];
      };
      telemetry_metrics = buildMix rec {
        name = "telemetry_metrics";
        version = "1.1.0";
        src = fetchHex {
          pkg = "telemetry_metrics";
          version = "${version}";
          sha256 = "e7b79e8ddfde70adb6db8a6623d1778ec66401f366e9a8f5dd0955c56bc8ce67";
        };
        beamDeps = [ telemetry ];
      };
      telemetry_poller = buildRebar3 rec {
        name = "telemetry_poller";
        version = "1.3.0";
        src = fetchHex {
          pkg = "telemetry_poller";
          version = "${version}";
          sha256 = "51f18bed7128544a50f75897db9974436ea9bfba560420b646af27a9a9b35211";
        };
        beamDeps = [ telemetry ];
      };
      thousand_island = buildMix rec {
        name = "thousand_island";
        version = "1.4.3";
        src = fetchHex {
          pkg = "thousand_island";
          version = "${version}";
          sha256 = "6e4ce09b0fd761a58594d02814d40f77daff460c48a7354a15ab353bb998ea0b";
        };
        beamDeps = [ telemetry ];
      };
      unicode_util_compat = buildRebar3 rec {
        name = "unicode_util_compat";
        version = "0.7.1";
        src = fetchHex {
          pkg = "unicode_util_compat";
          version = "${version}";
          sha256 = "b3a917854ce3ae233619744ad1e0102e05673136776fb2fa76234f3e03b23642";
        };
        beamDeps = [ ];
      };
      websock = buildMix rec {
        name = "websock";
        version = "0.5.3";
        src = fetchHex {
          pkg = "websock";
          version = "${version}";
          sha256 = "6105453d7fac22c712ad66fab1d45abdf049868f253cf719b625151460b8b453";
        };
        beamDeps = [ ];
      };
      websock_adapter = buildMix rec {
        name = "websock_adapter";
        version = "0.5.9";
        src = fetchHex {
          pkg = "websock_adapter";
          version = "${version}";
          sha256 = "5534d5c9adad3c18a0f58a9371220d75a803bf0b9a3d87e6fe072faaeed76a08";
        };
        beamDeps = [
          bandit
          plug
          websock
        ];
      };
    };
in
self
