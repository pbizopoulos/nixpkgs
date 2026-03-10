{ beamPackages
  , lib
  , overrides ? _x:
    _y:
      {} }:
  let
    buildMix = lib.makeOverridable (beamPackages.buildMix);
    buildRebar3 = lib.makeOverridable (beamPackages.buildRebar3);
    packages = with beamPackages;
    with self;
    {
      bandit = buildMix rec {
        beamDeps = [
          hpax
          plug
          telemetry
          thousand_island
          websock
        ];
        name = "bandit";
        src = fetchHex {
          pkg = "bandit";
          sha256 = "99a52d909c48db65ca598e1962797659e3c0f1d06e825a50c3d75b74a5e2db18";
          version = "${version}";
        };
        version = "1.10.3";
      };
      bcrypt_elixir = buildMix rec {
        beamDeps = [
          comeonin
          elixir_make
        ];
        name = "bcrypt_elixir";
        src = fetchHex {
          pkg = "bcrypt_elixir";
          sha256 = "471be5151874ae7931911057d1467d908955f93554f7a6cd1b7d804cac8cef53";
          version = "${version}";
        };
        version = "3.3.2";
      };
      comeonin = buildMix rec {
        beamDeps = [];
        name = "comeonin";
        src = fetchHex {
          pkg = "comeonin";
          sha256 = "65aac8f19938145377cee73973f192c5645873dcf550a8a6b18187d17c13ccdb";
          version = "${version}";
        };
        version = "5.5.1";
      };
      db_connection = buildMix rec {
        beamDeps = [
          telemetry
        ];
        name = "db_connection";
        src = fetchHex {
          pkg = "db_connection";
          sha256 = "17d502eacaf61829db98facf6f20808ed33da6ccf495354a41e64fe42f9c509c";
          version = "${version}";
        };
        version = "2.9.0";
      };
      decimal = buildMix rec {
        beamDeps = [];
        name = "decimal";
        src = fetchHex {
          pkg = "decimal";
          sha256 = "a4d66355cb29cb47c3cf30e71329e58361cfcb37c34235ef3bf1d7bf3773aeac";
          version = "${version}";
        };
        version = "2.3.0";
      };
      dns_cluster = buildMix rec {
        beamDeps = [];
        name = "dns_cluster";
        src = fetchHex {
          pkg = "dns_cluster";
          sha256 = "ba6f1893411c69c01b9e8e8f772062535a4cf70f3f35bcc964a324078d8c8240";
          version = "${version}";
        };
        version = "0.2.0";
      };
      ecto = buildMix rec {
        beamDeps = [
          decimal
          jason
          telemetry
        ];
        name = "ecto";
        src = fetchHex {
          pkg = "ecto";
          sha256 = "df9efebf70cf94142739ba357499661ef5dbb559ef902b68ea1f3c1fabce36de";
          version = "${version}";
        };
        version = "3.13.5";
      };
      ecto_sql = buildMix rec {
        beamDeps = [
          db_connection
          ecto
          postgrex
          telemetry
        ];
        name = "ecto_sql";
        src = fetchHex {
          pkg = "ecto_sql";
          sha256 = "aa36751f4e6a2b56ae79efb0e088042e010ff4935fc8684e74c23b1f49e25fdc";
          version = "${version}";
        };
        version = "3.13.5";
      };
      elixir_make = buildMix rec {
        beamDeps = [];
        name = "elixir_make";
        src = fetchHex {
          pkg = "elixir_make";
          sha256 = "db23d4fd8b757462ad02f8aa73431a426fe6671c80b200d9710caf3d1dd0ffdb";
          version = "${version}";
        };
        version = "0.9.0";
      };
      esbuild = buildMix rec {
        beamDeps = [
          jason
        ];
        name = "esbuild";
        src = fetchHex {
          pkg = "esbuild";
          sha256 = "468489cda427b974a7cc9f03ace55368a83e1a7be12fba7e30969af78e5f8c70";
          version = "${version}";
        };
        version = "0.10.0";
      };
      expo = buildMix rec {
        beamDeps = [];
        name = "expo";
        src = fetchHex {
          pkg = "expo";
          sha256 = "5fb308b9cb359ae200b7e23d37c76978673aa1b06e2b3075d814ce12c5811640";
          version = "${version}";
        };
        version = "1.1.1";
      };
      file_system = buildMix rec {
        beamDeps = [];
        name = "file_system";
        src = fetchHex {
          pkg = "file_system";
          sha256 = "7a15ff97dfe526aeefb090a7a9d3d03aa907e100e262a0f8f7746b78f8f87a5d";
          version = "${version}";
        };
        version = "1.1.1";
      };
      finch = buildMix rec {
        beamDeps = [
          mime
          mint
          nimble_options
          nimble_pool
          telemetry
        ];
        name = "finch";
        src = fetchHex {
          pkg = "finch";
          sha256 = "87dc6e169794cb2570f75841a19da99cfde834249568f2a5b121b809588a4377";
          version = "${version}";
        };
        version = "0.21.0";
      };
      gettext = buildMix rec {
        beamDeps = [
          expo
        ];
        name = "gettext";
        src = fetchHex {
          pkg = "gettext";
          sha256 = "eab805501886802071ad290714515c8c4a17196ea76e5afc9d06ca85fb1bfeb3";
          version = "${version}";
        };
        version = "1.0.2";
      };
      hpax = buildMix rec {
        beamDeps = [];
        name = "hpax";
        src = fetchHex {
          pkg = "hpax";
          sha256 = "8eab6e1cfa8d5918c2ce4ba43588e894af35dbd8e91e6e55c817bca5847df34a";
          version = "${version}";
        };
        version = "1.0.3";
      };
      idna = buildRebar3 rec {
        beamDeps = [
          unicode_util_compat
        ];
        name = "idna";
        src = fetchHex {
          pkg = "idna";
          sha256 = "92376eb7894412ed19ac475e4a86f7b413c1b9fbb5bd16dccd57934157944cea";
          version = "${version}";
        };
        version = "6.1.1";
      };
      jason = buildMix rec {
        beamDeps = [
          decimal
        ];
        name = "jason";
        src = fetchHex {
          pkg = "jason";
          sha256 = "c5eb0cab91f094599f94d55bc63409236a8ec69a21a67814529e8d5f6cc90b3b";
          version = "${version}";
        };
        version = "1.4.4";
      };
      mime = buildMix rec {
        beamDeps = [];
        name = "mime";
        src = fetchHex {
          pkg = "mime";
          sha256 = "6171188e399ee16023ffc5b76ce445eb6d9672e2e241d2df6050f3c771e80ccd";
          version = "${version}";
        };
        version = "2.0.7";
      };
      mint = buildMix rec {
        beamDeps = [
          hpax
        ];
        name = "mint";
        src = fetchHex {
          pkg = "mint";
          sha256 = "fceba0a4d0f24301ddee3024ae116df1c3f4bb7a563a731f45fdfeb9d39a231b";
          version = "${version}";
        };
        version = "1.7.1";
      };
      nimble_options = buildMix rec {
        beamDeps = [];
        name = "nimble_options";
        src = fetchHex {
          pkg = "nimble_options";
          sha256 = "821b2470ca9442c4b6984882fe9bb0389371b8ddec4d45a9504f00a66f650b44";
          version = "${version}";
        };
        version = "1.1.1";
      };
      nimble_pool = buildMix rec {
        beamDeps = [];
        name = "nimble_pool";
        src = fetchHex {
          pkg = "nimble_pool";
          sha256 = "af2e4e6b34197db81f7aad230c1118eac993acc0dae6bc83bac0126d4ae0813a";
          version = "${version}";
        };
        version = "1.1.0";
      };
      phoenix = buildMix rec {
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
        name = "phoenix";
        src = fetchHex {
          pkg = "phoenix";
          sha256 = "83b2bb125127e02e9f475c8e3e92736325b5b01b0b9b05407bcb4083b7a32485";
          version = "${version}";
        };
        version = "1.8.5";
      };
      phoenix_ecto = buildMix rec {
        beamDeps = [
          ecto
          phoenix_html
          plug
          postgrex
        ];
        name = "phoenix_ecto";
        src = fetchHex {
          pkg = "phoenix_ecto";
          sha256 = "1d75011e4254cb4ddf823e81823a9629559a1be93b4321a6a5f11a5306fbf4cc";
          version = "${version}";
        };
        version = "4.7.0";
      };
      phoenix_html = buildMix rec {
        beamDeps = [];
        name = "phoenix_html";
        src = fetchHex {
          pkg = "phoenix_html";
          sha256 = "3eaa290a78bab0f075f791a46a981bbe769d94bc776869f4f3063a14f30497ad";
          version = "${version}";
        };
        version = "4.3.0";
      };
      phoenix_live_dashboard = buildMix rec {
        beamDeps = [
          ecto
          mime
          phoenix_live_view
          telemetry_metrics
        ];
        name = "phoenix_live_dashboard";
        src = fetchHex {
          pkg = "phoenix_live_dashboard";
          sha256 = "3a8625cab39ec261d48a13b7468dc619c0ede099601b084e343968309bd4d7d7";
          version = "${version}";
        };
        version = "0.8.7";
      };
      phoenix_live_reload = buildMix rec {
        beamDeps = [
          file_system
          phoenix
        ];
        name = "phoenix_live_reload";
        src = fetchHex {
          pkg = "phoenix_live_reload";
          sha256 = "d1f89c18114c50d394721365ffb428cce24f1c13de0467ffa773e2ff4a30d5b9";
          version = "${version}";
        };
        version = "1.6.2";
      };
      phoenix_live_view = buildMix rec {
        beamDeps = [
          jason
          phoenix
          phoenix_html
          phoenix_template
          plug
          telemetry
        ];
        name = "phoenix_live_view";
        src = fetchHex {
          pkg = "phoenix_live_view";
          sha256 = "0ec34b24c69aa70c4f25a8901effe3462bee6c8ca80a9a4a7685215e3a0ac34e";
          version = "${version}";
        };
        version = "1.1.26";
      };
      phoenix_pubsub = buildMix rec {
        beamDeps = [];
        name = "phoenix_pubsub";
        src = fetchHex {
          pkg = "phoenix_pubsub";
          sha256 = "adc313a5bf7136039f63cfd9668fde73bba0765e0614cba80c06ac9460ff3e96";
          version = "${version}";
        };
        version = "2.2.0";
      };
      phoenix_template = buildMix rec {
        beamDeps = [
          phoenix_html
        ];
        name = "phoenix_template";
        src = fetchHex {
          pkg = "phoenix_template";
          sha256 = "2c0c81f0e5c6753faf5cca2f229c9709919aba34fab866d3bc05060c9c444206";
          version = "${version}";
        };
        version = "1.0.4";
      };
      plug = buildMix rec {
        beamDeps = [
          mime
          plug_crypto
          telemetry
        ];
        name = "plug";
        src = fetchHex {
          pkg = "plug";
          sha256 = "560a0017a8f6d5d30146916862aaf9300b7280063651dd7e532b8be168511e62";
          version = "${version}";
        };
        version = "1.19.1";
      };
      plug_crypto = buildMix rec {
        beamDeps = [];
        name = "plug_crypto";
        src = fetchHex {
          pkg = "plug_crypto";
          sha256 = "6470bce6ffe41c8bd497612ffde1a7e4af67f36a15eea5f921af71cf3e11247c";
          version = "${version}";
        };
        version = "2.1.1";
      };
      postgrex = buildMix rec {
        beamDeps = [
          db_connection
          decimal
          jason
        ];
        name = "postgrex";
        src = fetchHex {
          pkg = "postgrex";
          sha256 = "a68c4261e299597909e03e6f8ff5a13876f5caadaddd0d23af0d0a61afcc5d84";
          version = "${version}";
        };
        version = "0.22.0";
      };
      req = buildMix rec {
        beamDeps = [
          finch
          jason
          mime
          plug
        ];
        name = "req";
        src = fetchHex {
          pkg = "req";
          sha256 = "0b8bc6ffdfebbc07968e59d3ff96d52f2202d0536f10fef4dc11dc02a2a43e39";
          version = "${version}";
        };
        version = "0.5.17";
      };
      swoosh = buildMix rec {
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
        name = "swoosh";
        src = fetchHex {
          pkg = "swoosh";
          sha256 = "97aaf04481ce8a351e2d15a3907778bdf3b1ea071cfff3eb8728b65943c77f6d";
          version = "${version}";
        };
        version = "1.23.0";
      };
      tailwind = buildMix rec {
        beamDeps = [];
        name = "tailwind";
        src = fetchHex {
          pkg = "tailwind";
          sha256 = "6249d4f9819052911120dbdbe9e532e6bd64ea23476056adb7f730aa25c220d1";
          version = "${version}";
        };
        version = "0.4.1";
      };
      telemetry = buildRebar3 rec {
        beamDeps = [];
        name = "telemetry";
        src = fetchHex {
          pkg = "telemetry";
          sha256 = "7015fc8919dbe63764f4b4b87a95b7c0996bd539e0d499be6ec9d7f3875b79e6";
          version = "${version}";
        };
        version = "1.3.0";
      };
      telemetry_metrics = buildMix rec {
        beamDeps = [
          telemetry
        ];
        name = "telemetry_metrics";
        src = fetchHex {
          pkg = "telemetry_metrics";
          sha256 = "e7b79e8ddfde70adb6db8a6623d1778ec66401f366e9a8f5dd0955c56bc8ce67";
          version = "${version}";
        };
        version = "1.1.0";
      };
      telemetry_poller = buildRebar3 rec {
        beamDeps = [
          telemetry
        ];
        name = "telemetry_poller";
        src = fetchHex {
          pkg = "telemetry_poller";
          sha256 = "51f18bed7128544a50f75897db9974436ea9bfba560420b646af27a9a9b35211";
          version = "${version}";
        };
        version = "1.3.0";
      };
      thousand_island = buildMix rec {
        beamDeps = [
          telemetry
        ];
        name = "thousand_island";
        src = fetchHex {
          pkg = "thousand_island";
          sha256 = "6e4ce09b0fd761a58594d02814d40f77daff460c48a7354a15ab353bb998ea0b";
          version = "${version}";
        };
        version = "1.4.3";
      };
      unicode_util_compat = buildRebar3 rec {
        beamDeps = [];
        name = "unicode_util_compat";
        src = fetchHex {
          pkg = "unicode_util_compat";
          sha256 = "b3a917854ce3ae233619744ad1e0102e05673136776fb2fa76234f3e03b23642";
          version = "${version}";
        };
        version = "0.7.1";
      };
      websock = buildMix rec {
        beamDeps = [];
        name = "websock";
        src = fetchHex {
          pkg = "websock";
          sha256 = "6105453d7fac22c712ad66fab1d45abdf049868f253cf719b625151460b8b453";
          version = "${version}";
        };
        version = "0.5.3";
      };
      websock_adapter = buildMix rec {
        beamDeps = [
          bandit
          plug
          websock
        ];
        name = "websock_adapter";
        src = fetchHex {
          pkg = "websock_adapter";
          sha256 = "5534d5c9adad3c18a0f58a9371220d75a803bf0b9a3d87e6fe072faaeed76a08";
          version = "${version}";
        };
        version = "0.5.9";
      };
    };
    self = packages // overrides self packages;
  in self