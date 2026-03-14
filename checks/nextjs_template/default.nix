{
  inputs,
  pkgs,
  ...
}:
pkgs.testers.runNixOSTest rec {
  name = builtins.baseNameOf ./.;
  nodes.machine = {
    environment.systemPackages = [
      inputs.self.packages.${pkgs.stdenv.system}.${name}
      pkgs.docker
      pkgs.git
    ];
    virtualisation = {
      cores = 4;
      diskSize = 32768;
      docker.enable = true;
      memorySize = 16384;
    };
  };
  testScript =
    let
      images = [
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/edge-runtime";
          finalImageTag = "v1.70.0";
          hash = "sha256-gNzxklCQtzixXqMr03D00dJ+dwVLEFlxux36/w65aN0=";
          imageDigest = "sha256:d5b0545da7826404668c3a53809f217a9c7093526c7036c18e79ddc61e4cbe01";
          imageName = "public.ecr.aws/supabase/edge-runtime";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/gotrue";
          finalImageTag = "v2.186.0";
          hash = "sha256-JUzue8NIZzmHjhL9FiLI1KfR8n9fuh4ZukwwQPYr8LQ=";
          imageDigest = "sha256:f2112b9289422f205df4ea15b8b550d425ae42528ea54521faa32cc7b62490de";
          imageName = "public.ecr.aws/supabase/gotrue";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/imgproxy";
          finalImageTag = "v3.8.0";
          hash = "sha256-4hote3DE0OTJcid/6cxHPNrjwTo+Y6H/PT9qQdYLodY=";
          imageDigest = "sha256:0facd355d50f3be665ebe674486f2b2e9cdaebd3f74404acd9b7fece2f661435";
          imageName = "public.ecr.aws/supabase/imgproxy";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/kong";
          finalImageTag = "2.8.1";
          hash = "sha256-5A/sYrNKbeoAaWTUJ1azZVB0iaWYkF1NDfqrGIVVuTc=";
          imageDigest = "sha256:1b53405d8680a09d6f44494b7990bf7da2ea43f84a258c59717d4539abf09f6d";
          imageName = "public.ecr.aws/supabase/kong";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/logflare";
          finalImageTag = "1.30.5";
          hash = "sha256-t5w/4p/KJ1nuzZhpY+YAPgfgYfgaFPmJ7yR5QxZwA6M=";
          imageDigest = "sha256:7feaebcd43b0f62c67bfbf0a3f0f04b42b5f045f831d4c047d559a4f7673871c";
          imageName = "public.ecr.aws/supabase/logflare";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/mailpit";
          finalImageTag = "v1.22.3";
          hash = "sha256-ZRCFO9ydVyoW3nL122iQfQhl95g4qVf1q+Q6oymGWbM=";
          imageDigest = "sha256:f7f7c31de4de59540ad6515a0ca057a77525bca2069b6e747d873ca66c10fe08";
          imageName = "public.ecr.aws/supabase/mailpit";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/postgres";
          finalImageTag = "17.6.1.075";
          hash = "sha256-XNQAvkOMuHlDZmAoO9bjAVSoEZ9Q+4QAK7Q5/drboVo=";
          imageDigest = "sha256:82a04ba6c05f60950a74ae46be3726abb18d06ee44da936276fd782e72e36855";
          imageName = "public.ecr.aws/supabase/postgres";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/postgres-meta";
          finalImageTag = "v0.95.2";
          hash = "sha256-0OdT7bXj1lwVLtTnlqBIVCCn5u+nSMFrQ8D6q83lmGY=";
          imageDigest = "sha256:fd819ee65489a69e71f8811f447aeb9a796234f435c86173cbcce5e4c32b036e";
          imageName = "public.ecr.aws/supabase/postgres-meta";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/postgrest";
          finalImageTag = "v14.3";
          hash = "sha256-pgmyZYxQGA6wFB0aKrnHB5+WJJ97LYZke+CUyW8DQfE=";
          imageDigest = "sha256:7c5840727ad683b0fdbfb9810930665b34f8b44884a4dc740aa8844748a2b85e";
          imageName = "public.ecr.aws/supabase/postgrest";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/realtime";
          finalImageTag = "v2.73.2";
          hash = "sha256-m4diKBlrf1sxz4UlNGFvAEIB1sPwmFfQFavQafmYvLM=";
          imageDigest = "sha256:b872c3190e392b675be9e45816beceb6f4395450adecfc7c3057bcfb3cd0cdb5";
          imageName = "public.ecr.aws/supabase/realtime";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/storage-api";
          finalImageTag = "v1.35.3";
          hash = "sha256-vlYZqpUDjDPqllRRv3u4tcd5K2ZGrEaMCG7qJLBWOgg=";
          imageDigest = "sha256:5a3ecdc67dbe9e88a56810b5b2f432f2d93708dcb4dc9de34e78e342b390eb4d";
          imageName = "public.ecr.aws/supabase/storage-api";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/studio";
          finalImageTag = "2026.01.27-sha-2a37755";
          hash = "sha256-Q1p+xC5j2rHxXHILtTXAKyxfo3UCMhxVJkhL00JXxmQ=";
          imageDigest = "sha256:06c541e63395ff1a06150189edd598ed393fd81ae09059ae7558d3220311c49f";
          imageName = "public.ecr.aws/supabase/studio";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/supavisor";
          finalImageTag = "2.7.4";
          hash = "sha256-iJIhKsLBEVwp7Fa0PgZLMuVLkAENfWOswlfnXvCO2rs=";
          imageDigest = "sha256:466297ba00956e2d1cbd56a4362fbd5dbc9c2a47ad83e8ca9bdb877f743315ee";
          imageName = "public.ecr.aws/supabase/supavisor";
        })
        (pkgs.dockerTools.pullImage {
          finalImageName = "public.ecr.aws/supabase/vector";
          finalImageTag = "0.28.1-alpine";
          hash = "sha256-qduccmkSlNi7V6VLuG5lALilAjpdSrAi/8F13EFwKWg=";
          imageDigest = "sha256:4bc04aca94a44f04b427a490f346e7397ef7ce61fe589d718f744f7d92cb5c80";
          imageName = "public.ecr.aws/supabase/vector";
        })
      ];
    in
    ''
      machine.wait_for_unit("docker.service")
    ''
    + pkgs.lib.concatStringsSep "\n" (
      map (image: "machine.succeed(\"docker load -i ${image}\")") images
    )
    + "\n"
    + ''
      machine.succeed("DEBUG=1 ${name}")
    '';
}
