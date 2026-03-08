defmodule PhoenixApp do
  @moduledoc """
  PhoenixApp keeps the contexts that define your domain
  and business logic.
  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def main(_args) do
    if Application.get_env(:phoenix_app, PhoenixApp.Repo) == nil do
      Application.put_env(:phoenix_app, PhoenixApp.Repo,
        username: "postgres",
        password: "postgres",
        hostname: "127.0.0.1",
        database: "postgres",
        port: 54322,
        stacktrace: true,
        pool_size: 10
      )
    end
    if Application.get_env(:phoenix_app, PhoenixAppWeb.Endpoint) == nil do
      Application.put_env(:phoenix_app, PhoenixAppWeb.Endpoint,
        url: [host: "localhost"],
        adapter: Bandit.PhoenixAdapter,
        render_errors: [
          formats: [html: PhoenixAppWeb.ErrorHTML, json: PhoenixAppWeb.ErrorJSON],
          layout: false
        ],
        pubsub_server: PhoenixApp.PubSub,
        live_view: [signing_salt: "NGmKbuNC"],
        secret_key_base: "mxbDvgdIuQjSmuC4Dv1QdLR6P7GZziecN1iZ//PfSFaYbdAcdi5Ia4XMtMw7ZtaH",
        http: [port: String.to_integer(System.get_env("PORT") || "4000")],
        server: true
      )
    end
    if System.get_env("DEBUG") == "1" do
      IO.puts("Smoke testing PhoenixApp...")
      Application.ensure_all_started(:phoenix_app)
      IO.puts("PhoenixApp started successfully!")
      System.halt(0)
    else
      IO.puts("Starting Phoenix server...")
      Application.ensure_all_started(:phoenix_app)
      Process.sleep(:infinity)
    end
  end
end
