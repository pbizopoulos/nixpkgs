import Config
config :bcrypt_elixir, :log_rounds, 1
config :phoenix_app, PhoenixApp.Repo,
  username: "supabase",
  password: "supabase",
  hostname: "127.0.0.1",
  database: "supabase",
  port: 54322,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2
config :phoenix_app, PhoenixAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "sBAMrvKjOUPYSGd4k+Eadx6UnlLasl3p+1w6ld+duQNYSIpEYWyJRPtJln8dswMJ",
  server: false
config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
config :phoenix,
  sort_verified_routes_query_params: true
