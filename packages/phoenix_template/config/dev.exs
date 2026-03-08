import Config
config :phoenix_app, PhoenixAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "mxbDvgdIuQjSmuC4Dv1QdLR6P7GZziecN1iZ//PfSFaYbdAcdi5Ia4XMtMw7ZtaH",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:phoenix_app, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:phoenix_app, ~w(--watch)]}
  ]
config :phoenix_app, PhoenixAppWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*\.po$",
      ~r"lib/phoenix_app_web/router\.ex$",
      ~r"lib/phoenix_app_web/(controllers|live|components)/.*\.(ex|heex)$"
    ]
  ]
config :phoenix_app, dev_routes: true
config :logger, :default_formatter, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
config :phoenix_live_view,
  debug_heex_annotations: true,
  debug_attributes: true,
  enable_expensive_runtime_checks: true
