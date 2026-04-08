{
  config,
  lib,
  ...
}:
let
  cfg = config.services.django-app;
  pgcfg = cfg.postgresql;
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.environmentFile != null;
        message = "services.django-app requires environmentFile.";
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
          inherit (cfg.nginx) enableACME;
          inherit (cfg.nginx) forceSSL;
          default = cfg.nginx.defaultVirtualHost;
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
        ALLOWED_HOSTS = lib.concatStringsSep "," cfg.allowedHosts;
        APP_NAME = cfg.appName;
        CSRF_COOKIE_SECURE = lib.boolToString cfg.nginx.forceSSL;
        CSRF_TRUSTED_ORIGINS = lib.concatStringsSep "," cfg.csrfTrustedOrigins;
        DATABASE_ENGINE = if pgcfg.enable then "postgresql" else "sqlite3";
        DATABASE_NAME = if pgcfg.enable then pgcfg.database else "/var/lib/${cfg.name}/${cfg.name}.sqlite3";
        DB_HOST = pgcfg.host;
        DB_PORT = toString pgcfg.port;
        DB_USER = pgcfg.user;
        DEFAULT_FROM_EMAIL = cfg.defaultFromEmail;
        EMAIL_BACKEND = cfg.emailBackend;
        HOST = cfg.host;
        PORT = toString cfg.port;
        SECURE_HSTS_SECONDS = if cfg.nginx.forceSSL then "15552000" else "0";
        SECURE_PROXY_SSL_HEADER = lib.boolToString cfg.nginx.forceSSL;
        SECURE_SSL_REDIRECT = lib.boolToString cfg.nginx.forceSSL;
        SESSION_COOKIE_SECURE = lib.boolToString cfg.nginx.forceSSL;
        STATIC_ROOT = "/var/lib/${cfg.name}/staticfiles";
        SUPPORT_EMAIL = cfg.supportEmail;
      }
      // cfg.extraEnvironment;
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/${cfg.executable}";
        ExecStartPre = lib.optionals cfg.runMigrations [
          "${cfg.package}/bin/${cfg.manageExecutable} migrate --noinput"
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
  options.services.django-app = {
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
      default = "Django Starter";
      description = "Application name exposed as APP_NAME.";
      type = lib.types.str;
    };
    csrfTrustedOrigins = lib.mkOption {
      default = [ ];
      description = "Trusted CSRF origins exposed through CSRF_TRUSTED_ORIGINS.";
      type = lib.types.listOf lib.types.str;
    };
    defaultFromEmail = lib.mkOption {
      default = "starter@example.com";
      description = "Default sender address for outbound email.";
      type = lib.types.str;
    };
    emailBackend = lib.mkOption {
      default = "django.core.mail.backends.console.EmailBackend";
      description = "Django email backend for the service.";
      type = lib.types.str;
    };
    enable = lib.mkEnableOption "Django application service";
    environmentFile = lib.mkOption {
      default = null;
      description = "Optional systemd EnvironmentFile for secrets like SECRET_KEY.";
      type = lib.types.nullOr lib.types.path;
    };
    executable = lib.mkOption {
      default = cfg.name;
      defaultText = lib.literalExpression "config.services.django-app.name";
      description = "The executable name under the package's bin directory.";
      type = lib.types.str;
    };
    extraEnvironment = lib.mkOption {
      default = { };
      description = "Additional environment variables for the Django service.";
      type = lib.types.attrsOf lib.types.str;
    };
    host = lib.mkOption {
      default = "127.0.0.1";
      description = "Listen host exposed as HOST.";
      type = lib.types.str;
    };
    manageExecutable = lib.mkOption {
      default = "${cfg.executable}-manage";
      defaultText = lib.literalExpression ''
        "${config.services.django-app.executable}-manage"
      '';
      description = "The executable name under the package's bin directory used for management commands.";
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
        description = "Whether to expose the Django service behind nginx on port 80.";
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
      description = "The packaged Django application to run.";
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
        defaultText = lib.literalExpression "config.services.django-app.name";
        description = "Database name exposed as DATABASE_NAME.";
        type = lib.types.str;
      };
      enable = lib.mkOption {
        default = true;
        description = "Whether to provision PostgreSQL for the Django service.";
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
      user = lib.mkOption {
        default = cfg.name;
        defaultText = lib.literalExpression "config.services.django-app.name";
        description = "Database user exposed as DB_USER.";
        type = lib.types.str;
      };
    };
    runMigrations = lib.mkOption {
      default = true;
      description = "Whether to run database migrations before starting the service.";
      type = lib.types.bool;
    };
    supportEmail = lib.mkOption {
      default = "support@example.com";
      description = "Support email address exposed as SUPPORT_EMAIL.";
      type = lib.types.str;
    };
  };
}
