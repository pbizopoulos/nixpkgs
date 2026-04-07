{
  config,
  lib,
  ...
}:
let
  backendDefaults = {
    adonisjs = {
      appName = "AdonisJS Starter";
      packageAttrName = "adonisjs-template";
      port = 3333;
    };
    django = {
      appName = "Django Starter";
      packageAttrName = "django_template";
      port = 8000;
    };
    fastapi-postgres = {
      appName = "FastAPI Postgres Starter";
      packageAttrName = "fastapi_postgres_template";
      port = 8000;
    };
  };
  backendType = lib.types.enum [
    "adonisjs"
    "django"
    "fastapi-postgres"
  ];
  cfg = config.services.template-app;
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (cfg.backend == "adonisjs") {
        services.adonisjs-app = {
          inherit (cfg) addToSystemPackages;
          inherit (cfg) appKey;
          inherit (cfg) environmentFile;
          inherit (cfg) extraEnvironment;
          inherit (cfg) host;
          inherit (cfg) name;
          inherit (cfg) nginx;
          inherit (cfg) package;
          inherit (cfg) port;
          inherit (cfg) runMigrations;
          appUrl = if cfg.publicUrl != null then cfg.publicUrl else "http://${cfg.host}:${toString cfg.port}";
          enable = true;
          postgresql = {
            inherit (cfg.postgresql)
              database
              enable
              host
              password
              port
              ssl
              user
              ;
          };
        }
        // lib.optionalAttrs (cfg.executable != null) {
          inherit (cfg) executable;
        }
        // lib.optionalAttrs (cfg.migrationExecutable != null) {
          inherit (cfg) migrationExecutable;
        };
      })
      (lib.mkIf (cfg.backend == "django") {
        services.django-app = {
          inherit (cfg) addToSystemPackages;
          inherit (cfg) allowedHosts;
          inherit (cfg) appName;
          inherit (cfg) csrfTrustedOrigins;
          inherit (cfg) defaultFromEmail;
          inherit (cfg) emailBackend;
          inherit (cfg) environmentFile;
          inherit (cfg) extraEnvironment;
          inherit (cfg) host;
          inherit (cfg) name;
          inherit (cfg) nginx;
          inherit (cfg) package;
          inherit (cfg) port;
          inherit (cfg) runMigrations;
          inherit (cfg) secretKey;
          inherit (cfg) supportEmail;
          enable = true;
          postgresql = {
            inherit (cfg.postgresql)
              database
              enable
              host
              password
              port
              user
              ;
          };
        }
        // lib.optionalAttrs (cfg.executable != null) {
          inherit (cfg) executable;
        }
        // lib.optionalAttrs (cfg.manageExecutable != null) {
          inherit (cfg) manageExecutable;
        };
      })
      (lib.mkIf (cfg.backend == "fastapi-postgres") {
        services.fastapi-postgres-app = {
          inherit (cfg) addToSystemPackages;
          inherit (cfg) allowedHosts;
          inherit (cfg) appName;
          inherit (cfg) environmentFile;
          inherit (cfg) extraEnvironment;
          inherit (cfg) host;
          inherit (cfg) name;
          inherit (cfg) nginx;
          inherit (cfg) package;
          inherit (cfg) port;
          inherit (cfg) secretKey;
          inherit (cfg) supportEmail;
          enable = true;
          postgresql = {
            inherit (cfg.postgresql)
              database
              enable
              host
              password
              port
              user
              ;
          };
        }
        // lib.optionalAttrs (cfg.executable != null) {
          inherit (cfg) executable;
        };
      })
    ]
  );
  imports = [
    ./adonisjs.nix
    ./django.nix
    ./fastapi-postgres.nix
  ];
  options.services.template-app = {
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
      description = "Allowed hosts for backends that use host allow-lists.";
      type = lib.types.listOf lib.types.str;
    };
    appKey = lib.mkOption {
      default = null;
      description = "Optional AdonisJS APP_KEY to inject directly into the service environment.";
      type = lib.types.nullOr lib.types.str;
    };
    appName = lib.mkOption {
      default = backendDefaults.${cfg.backend}.appName;
      defaultText = lib.literalExpression ''
        {
          adonisjs = "AdonisJS Starter";
          django = "Django Starter";
          fastapi-postgres = "FastAPI Postgres Starter";
        }.${config.services.template-app.backend}
      '';
      description = "Application name for backends that expose APP_NAME.";
      type = lib.types.str;
    };
    backend = lib.mkOption {
      description = "Which backend implementation to run for this template host.";
      type = backendType;
    };
    csrfTrustedOrigins = lib.mkOption {
      default = [ ];
      description = "Trusted CSRF origins for Django backends.";
      type = lib.types.listOf lib.types.str;
    };
    defaultFromEmail = lib.mkOption {
      default = "starter@example.com";
      description = "Default sender address for backends that expose it.";
      type = lib.types.str;
    };
    emailBackend = lib.mkOption {
      default = "django.core.mail.backends.console.EmailBackend";
      description = "Email backend for frameworks that expose it.";
      type = lib.types.str;
    };
    enable = lib.mkEnableOption "template application service";
    environmentFile = lib.mkOption {
      default = null;
      description = "Optional systemd EnvironmentFile for secrets such as APP_KEY or SECRET_KEY.";
      type = lib.types.nullOr lib.types.path;
    };
    executable = lib.mkOption {
      default = null;
      description = "Optional override for the package executable name.";
      type = lib.types.nullOr lib.types.str;
    };
    extraEnvironment = lib.mkOption {
      default = { };
      description = "Additional environment variables for the selected backend service.";
      type = lib.types.attrsOf lib.types.str;
    };
    host = lib.mkOption {
      default = "127.0.0.1";
      description = "Listen host exposed as HOST.";
      type = lib.types.str;
    };
    manageExecutable = lib.mkOption {
      default = null;
      description = "Optional override for the Django management executable name.";
      type = lib.types.nullOr lib.types.str;
    };
    migrationExecutable = lib.mkOption {
      default = null;
      description = "Optional override for the AdonisJS migration executable name.";
      type = lib.types.nullOr lib.types.str;
    };
    name = lib.mkOption {
      default = cfg.packageAttrName;
      defaultText = lib.literalExpression "config.services.template-app.packageAttrName";
      description = "The systemd service, user, and group name for the selected backend.";
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
        description = "Whether to expose the selected backend behind nginx on port 80.";
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
      description = "The packaged application corresponding to the selected backend.";
      type = lib.types.package;
    };
    packageAttrName = lib.mkOption {
      default = backendDefaults.${cfg.backend}.packageAttrName;
      defaultText = lib.literalExpression ''
        {
          adonisjs = "adonisjs-template";
          django = "django_template";
          fastapi-postgres = "fastapi_postgres_template";
        }.${config.services.template-app.backend}
      '';
      description = "The flake package attribute corresponding to the selected backend.";
      type = lib.types.str;
    };
    port = lib.mkOption {
      default = backendDefaults.${cfg.backend}.port;
      defaultText = lib.literalExpression ''
        {
          adonisjs = 3333;
          django = 8000;
          fastapi-postgres = 8000;
        }.${config.services.template-app.backend}
      '';
      description = "Listen port for the selected backend.";
      type = lib.types.port;
    };
    postgresql = {
      database = lib.mkOption {
        default = cfg.name;
        defaultText = lib.literalExpression "config.services.template-app.name";
        description = "Database name for the selected backend.";
        type = lib.types.str;
      };
      enable = lib.mkOption {
        default = true;
        description = "Whether to provision PostgreSQL for the selected backend.";
        type = lib.types.bool;
      };
      host = lib.mkOption {
        default = "/run/postgresql";
        description = "Database host for the selected backend.";
        type = lib.types.str;
      };
      password = lib.mkOption {
        default = "postgres";
        description = "Database password for the selected backend.";
        type = lib.types.str;
      };
      port = lib.mkOption {
        default = 5432;
        description = "Database port for the selected backend.";
        type = lib.types.port;
      };
      ssl = lib.mkOption {
        default = false;
        description = "Whether to expose SSL database configuration where supported.";
        type = lib.types.bool;
      };
      user = lib.mkOption {
        default = cfg.name;
        defaultText = lib.literalExpression "config.services.template-app.name";
        description = "Database user for the selected backend.";
        type = lib.types.str;
      };
    };
    publicUrl = lib.mkOption {
      default = null;
      description = "Optional public URL for backends that expose APP_URL.";
      type = lib.types.nullOr lib.types.str;
    };
    runMigrations = lib.mkOption {
      default = true;
      description = "Whether to run packaged migrations before starting the selected backend when supported.";
      type = lib.types.bool;
    };
    secretKey = lib.mkOption {
      default = null;
      description = "Optional SECRET_KEY to inject directly into backends that use it.";
      type = lib.types.nullOr lib.types.str;
    };
    supportEmail = lib.mkOption {
      default = "support@example.com";
      description = "Support email address for backends that expose it.";
      type = lib.types.str;
    };
  };
}
