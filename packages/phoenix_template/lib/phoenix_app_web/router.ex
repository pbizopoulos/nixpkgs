defmodule PhoenixAppWeb.Router do
  use PhoenixAppWeb, :router
  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {PhoenixAppWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end
  pipeline :api do
    plug(:accepts, ["json"])
  end
  scope "/", PhoenixAppWeb do
    pipe_through(:browser)
    get("/", PageController, :home)
  end
  if Application.compile_env(:phoenix_app, :dev_routes) do
    import Phoenix.LiveDashboard.Router
    scope "/dev" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: PhoenixAppWeb.Telemetry)
    end
  end
end
