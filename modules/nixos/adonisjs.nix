{
  config,
  lib,
  ...
}:
let
  cfg = config.services.adonisjs-app;
  pgcfg = cfg.postgresql;
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.environmentFile != null;
        message = "services.adonisjs-app requires environmentFile.";
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
          inherit (cfg.nginx) enableACME;
          inherit (cfg.nginx) forceSSL;
          locations."/" = {
            proxyPass = "http://${cfg.host}:${toString cfg.port}";
            recommendedProxySettings = true;
          };
        }
        // lib.optionalAttrs (cfg.nginx.useACMEHost != null) {
          inherit (cfg.nginx) useACMEHost;
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
        APP_URL = cfg.appUrl;
        DB_DATABASE = pgcfg.database;
        DB_HOST = pgcfg.host;
        DB_PASSWORD = "peer-auth";
        DB_PORT = toString pgcfg.port;
        DB_SSL = lib.boolToString pgcfg.ssl;
        DB_USER = pgcfg.user;
        HOST = cfg.host;
        PORT = toString cfg.port;
      }
      // cfg.extraEnvironment;
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/${cfg.executable}";
        ExecStartPre = lib.optionals cfg.runMigrations [
          "${cfg.package}/bin/${cfg.migrationExecutable}"
        ];
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
  options.services.adonisjs-app = {
    addToSystemPackages = lib.mkOption {
      default = true;
      description = "Install the packaged application into environment.systemPackages.";
      type = lib.types.bool;
    };
    appUrl = lib.mkOption {
      description = "Public application URL exposed as APP_URL.";
      type = lib.types.str;
    };
    enable = lib.mkEnableOption "AdonisJS application service";
    environmentFile = lib.mkOption {
      default = null;
      description = "Optional systemd EnvironmentFile for secrets like APP_KEY.";
      type = lib.types.nullOr lib.types.path;
    };
    executable = lib.mkOption {
      default = cfg.name;
      defaultText = lib.literalExpression "config.services.adonisjs-app.name";
      description = "The executable name under the package's bin directory.";
      type = lib.types.str;
    };
    extraEnvironment = lib.mkOption {
      default = { };
      description = "Additional environment variables for the AdonisJS service.";
      type = lib.types.attrsOf lib.types.str;
    };
    host = lib.mkOption {
      default = "127.0.0.1";
      description = "Listen host exposed as HOST.";
      type = lib.types.str;
    };
    migrationExecutable = lib.mkOption {
      default = "${cfg.executable}-migrate";
      defaultText = lib.literalExpression ''
        "${config.services.adonisjs-app.executable}-migrate"
      '';
      description = "The executable name under the package's bin directory used for database migrations.";
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
        description = "Whether to expose the AdonisJS service behind nginx on port 80.";
        type = lib.types.bool;
      };
      enableACME = lib.mkOption {
        default = false;
        description = "Whether nginx should request ACME certificates for this virtual host.";
        type = lib.types.bool;
      };
      forceSSL = lib.mkOption {
        default = false;
        description = "Whether nginx should redirect HTTP traffic to HTTPS for this virtual host.";
        type = lib.types.bool;
      };
      serverName = lib.mkOption {
        default = config.networking.hostName;
        defaultText = lib.literalExpression "config.networking.hostName";
        description = "nginx virtual host name.";
        type = lib.types.str;
      };
      useACMEHost = lib.mkOption {
        default = null;
        description = "Optional ACME host to reuse instead of enabling ACME directly on this virtual host.";
        type = lib.types.nullOr lib.types.str;
      };
    };
    package = lib.mkOption {
      description = "The packaged AdonisJS application to run.";
      type = lib.types.package;
    };
    port = lib.mkOption {
      default = 3333;
      description = "Listen port exposed as PORT.";
      type = lib.types.port;
    };
    postgresql = {
      database = lib.mkOption {
        default = cfg.name;
        defaultText = lib.literalExpression "config.services.adonisjs-app.name";
        description = "Database name exposed as DB_DATABASE.";
        type = lib.types.str;
      };
      enable = lib.mkOption {
        default = true;
        description = "Whether to provision PostgreSQL for the AdonisJS service.";
        type = lib.types.bool;
      };
      host = lib.mkOption {
        default = "/run/postgresql";
        description = "Database host exposed as DB_HOST.";
        type = lib.types.str;
      };
      port = lib.mkOption {
        default = 5432;
        description = "Database port exposed as DB_PORT.";
        type = lib.types.port;
      };
      ssl = lib.mkOption {
        default = false;
        description = "Whether to expose DB_SSL=true for the application.";
        type = lib.types.bool;
      };
      user = lib.mkOption {
        default = cfg.name;
        defaultText = lib.literalExpression "config.services.adonisjs-app.name";
        description = "Database user exposed as DB_USER.";
        type = lib.types.str;
      };
    };
    runMigrations = lib.mkOption {
      default = true;
      description = "Whether to run the packaged migration executable before starting the service.";
      type = lib.types.bool;
    };
  };
}
