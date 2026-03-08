defmodule PhoenixApp.Accounts.UserNotifier do
  defp deliver(recipient, subject, body) do
    IO.inspect({recipient, subject, body}, label: "UserNotifier.deliver")
    {:ok, %{recipient: recipient, subject: subject, body: body}}
  end
  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """
    ==============================
    Hi #{user.email},
    You can change your email by visiting the URL below:
    #{url}
    If you didn't request this change, please ignore this.
    ==============================
    """)
  end
  @doc """
  Deliver instructions to log in with a magic link.
  """
  def deliver_login_instructions(user, url) do
    deliver_magic_link_instructions(user, url)
  end
  defp deliver_magic_link_instructions(user, url) do
    deliver(user.email, "Log in instructions", """
    ==============================
    Hi #{user.email},
    You can log into your account by visiting the URL below:
    #{url}
    If you didn't request this email, please ignore this.
    ==============================
    """)
  end
  defp deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """
    ==============================
    Hi #{user.email},
    You can confirm your account by visiting the URL below:
    #{url}
    If you didn't create an account with us, please ignore this.
    ==============================
    """)
  end
end
