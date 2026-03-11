defmodule PhoenixAppWeb.UserProfileController do
  use PhoenixAppWeb, :controller
  alias PhoenixApp.Accounts

  def show(conn, %{"username" => username}) do
    if user = Accounts.get_user_by_username(username) do
      render(conn, :show, user: user)
    else
      conn
      |> put_status(:not_found)
      |> put_view(PhoenixAppWeb.ErrorHTML)
      |> render(:"404")
    end
  end
end
