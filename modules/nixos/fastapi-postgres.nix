{
  config,
  lib,
  ...
}:
let
  cfg = config.services.fastapi-postgres-app;
  databaseUrl =
    if pgcfg.enable then
      "postgresql+psycopg://${pgcfg.user}:${pgcfg.password}@${pgcfg.host}:${toString pgcfg.port}/${pgcfg.database}"
    else
      "sqlite:////var/lib/${cfg.name}/${cfg.name}.sqlite3";
  pgcfg = cfg.postgresql;
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.secretKey != null || cfg.environmentFile != null;
        message = "services.fastapi-postgres-app requires either secretKey or environmentFile.";
      }
    ];
    environment.systemPackages = lib.mkIf cfg.addToSystemPackages [
      cfg.package
    ];
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.nginx.enable [
      80
    ];
    services = {
      nginx = lib.mkIf cfg.nginx.enable {
        enable = true;
        virtualHosts.${cfg.nginx.serverName} = {
          default = cfg.nginx.defaultVirtualHost;
          locations."/" = {
            proxyPass = "http://${cfg.host}:${toString cfg.port}";
            recommendedProxySettings = true;
          };
        };
      };
      postgresql = lib.mkIf pgcfg.enable {
        enable = true;
        ensureDatabases = [
          pgcfg.database
        ];
        ensureUsers = [
          {
            ensureDBOwnership = true;
            name = pgcfg.user;
          }
        ];
      };
    };
    systemd.services.${cfg.name} = {
      after = [
        "network.target"
      ]
      ++ lib.optional pgcfg.enable "postgresql.service";
      environment = {
        ALLOWED_HOSTS = lib.concatStringsSep "," cfg.allowedHosts;
        APP_NAME = cfg.appName;
        DATABASE_URL = databaseUrl;
        HOST = cfg.host;
        PORT = toString cfg.port;
        SUPPORT_EMAIL = cfg.supportEmail;
      }
      // lib.optionalAttrs (cfg.secretKey != null) {
        SECRET_KEY = cfg.secretKey;
      }
      // cfg.extraEnvironment;
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/${cfg.executable}";
        Group = cfg.name;
        Restart = "always";
        RestartSec = 5;
        StateDirectory = cfg.name;
        User = cfg.name;
      }
      // lib.optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };
      wantedBy = [
        "multi-user.target"
      ];
    };
    users = {
      groups.${cfg.name} = { };
      users.${cfg.name} = {
        group = cfg.name;
        home = "/var/lib/${cfg.name}";
        isSystemUser = true;
      };
    };
  };
  options.services.fastapi-postgres-app = {
    addToSystemPackages = lib.mkOption {
      default = true;
      description = "Install the packaged application into environment.systemPackages.";
      type = lib.types.bool;
    };
    allowedHosts = lib.mkOption {
      default = [
        "127.0.0.1"
        "localhost"
        "[::1]"
      ];
      description = "Allowed hosts exposed through ALLOWED_HOSTS.";
      type = lib.types.listOf lib.types.str;
    };
    appName = lib.mkOption {
      default = "FastAPI Postgres Starter";
      description = "Application name exposed as APP_NAME.";
      type = lib.types.str;
    };
    enable = lib.mkEnableOption "FastAPI Postgres application service";
    environmentFile = lib.mkOption {
      default = null;
      description = "Optional systemd EnvironmentFile for secrets like SECRET_KEY.";
      type = lib.types.nullOr lib.types.path;
    };
    executable = lib.mkOption {
      default = cfg.name;
      defaultText = lib.literalExpression "config.services.fastapi-postgres-app.name";
      description = "The executable name under the package's bin directory.";
      type = lib.types.str;
    };
    extraEnvironment = lib.mkOption {
      default = { };
      description = "Additional environment variables for the FastAPI service.";
      type = lib.types.attrsOf lib.types.str;
    };
    host = lib.mkOption {
      default = "127.0.0.1";
      description = "Listen host exposed as HOST.";
      type = lib.types.str;
    };
    name = lib.mkOption {
      description = "The systemd service, user, and group name.";
      type = lib.types.str;
    };
    nginx = {
      defaultVirtualHost = lib.mkOption {
        default = false;
        description = "Whether to mark the nginx virtual host as default.";
        type = lib.types.bool;
      };
      enable = lib.mkOption {
        default = true;
        description = "Whether to expose the FastAPI service behind nginx on port 80.";
        type = lib.types.bool;
      };
      serverName = lib.mkOption {
        default = config.networking.hostName;
        defaultText = lib.literalExpression "config.networking.hostName";
        description = "nginx virtual host name.";
        type = lib.types.str;
      };
    };
    package = lib.mkOption {
      description = "The packaged FastAPI application to run.";
      type = lib.types.package;
    };
    port = lib.mkOption {
      default = 8000;
      description = "Listen port exposed as PORT.";
      type = lib.types.port;
    };
    postgresql = {
      database = lib.mkOption {
        default = cfg.name;
        defaultText = lib.literalExpression "config.services.fastapi-postgres-app.name";
        description = "Database name exposed through DATABASE_URL.";
        type = lib.types.str;
      };
      enable = lib.mkOption {
        default = true;
        description = "Whether to provision PostgreSQL for the FastAPI service.";
        type = lib.types.bool;
      };
      host = lib.mkOption {
        default = "/run/postgresql";
        description = "Database host exposed through DATABASE_URL.";
        type = lib.types.str;
      };
      password = lib.mkOption {
        default = "postgres";
        description = "Database password exposed through DATABASE_URL.";
        type = lib.types.str;
      };
      port = lib.mkOption {
        default = 5432;
        description = "Database port exposed through DATABASE_URL.";
        type = lib.types.port;
      };
      user = lib.mkOption {
        default = cfg.name;
        defaultText = lib.literalExpression "config.services.fastapi-postgres-app.name";
        description = "Database user exposed through DATABASE_URL.";
        type = lib.types.str;
      };
    };
    secretKey = lib.mkOption {
      default = null;
      description = "Optional SECRET_KEY to inject directly into the service environment.";
      type = lib.types.nullOr lib.types.str;
    };
    supportEmail = lib.mkOption {
      default = "support@example.com";
      description = "Support address exposed as SUPPORT_EMAIL.";
      type = lib.types.str;
    };
  };
}
