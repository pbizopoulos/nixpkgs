import Config
config :phoenix_app, :scopes,
  user: [
    default: true,
    module: PhoenixApp.Accounts.Scope,
    assign_key: :current_scope,
    access_path: [:user, :id],
    schema_key: :user_id,
    schema_type: :binary_id,
    schema_table: :users,
    test_data_fixture: PhoenixApp.AccountsFixtures,
    test_setup_helper: :register_and_log_in_user
  ]
config :phoenix_app,
  ecto_repos: [PhoenixApp.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]
config :phoenix_app, PhoenixAppWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: PhoenixAppWeb.ErrorHTML, json: PhoenixAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PhoenixApp.PubSub,
  live_view: [signing_salt: "NGmKbuNC"]
config :esbuild,
  version: "0.25.4",
  phoenix_app: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]
config :tailwind,
  version: "4.1.12",
  phoenix_app: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
config :phoenix, :json_library, Jason
import_config "#{config_env()}.exs"
