import Config
config :phoenix_app, PhoenixApp.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "phoenix_app_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2
config :phoenix_app, PhoenixAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "sBAMrvKjOUPYSGd4k+Eadx6UnlLasl3p+1w6ld+duQNYSIpEYWyJRPtJln8dswMJ",
  server: false
config :phoenix_app, PhoenixApp.Mailer, adapter: Swoosh.Adapters.Test
config :swoosh, :api_client, false
config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
config :phoenix,
  sort_verified_routes_query_params: true
