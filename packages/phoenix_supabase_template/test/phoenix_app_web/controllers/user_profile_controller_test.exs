defmodule PhoenixAppWeb.UserProfileControllerTest do
  use PhoenixAppWeb.ConnCase, async: true
  import PhoenixApp.AccountsFixtures

  describe "show" do
    test "renders user profile when user exists", %{conn: conn} do
      user = user_fixture()
      conn = get(conn, ~p"/\#{user.username}")
      response = html_response(conn, 200)
      assert response =~ user.username
      assert response =~ "This is a minimal profile page"
    end

    test "renders 404 when user does not exist", %{conn: conn} do
      conn = get(conn, ~p"/non-existent-user")
      assert html_response(conn, 404)
    end
  end
end
