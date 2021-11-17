defmodule YourAppWeb.CloveSsoController do
  @moduledoc """
  We provide a controller example for Elixir, but it's simple to add this to an existing app.
  You'll likely be using a login system like Pow or gen.auth. You can add a route to your Phoenix Router
  like:

  ```
  # router.ex

  scope "/", YourAppWeb do
    pipe_through [:authenticated, :browser]

    get "/sso/clove", CloveSsoController, :sso_redirect
  end
  ```

  And a config value for your secret, like:

  ```
  # runtime.exs

  config :clove, :clove_sso, secret: System.get_env("CLOVE_SSO_SECRET")
  ```
  """

  use YourAppWeb, :controller

  # This should be your hub domain, like hub.cloveapp.io or support.example.com
  # This check prevents SSO hijacking
  @allowed_domains ["help.yourcompany.com"]

  def sso_redirect(conn = %{assigns: %{current_user: user}}, %{"hub_domain" => domain}) when domain in @allowed_domains do
    # The specific of how current_user or "organization" gets here is up to your application
    # You can pass `nil` for the organization to not associate the user to one
    user_payload = %{
      "id" => user.id,
      "given_name" => user.first_name,
      "family_name" => user.last_name,
      "name" => full_name(user),
      "email" => user.email,
      "custom_data" => %{},
      "organization" => %{
        "id" => user.organization.id,
        "name" => user.organization.name,
        "custom_data" => %{}
      }
    }

    jwt = sign_payload(%{"user" => user_payload})

    redirect(conn, external: "https://#{domain}/sso/jwt?jwt=#{jwt}")
  end

  defp full_name(user) do
    [user.first_name, user.last_name]
    |> Enum.join(" ")
    |> String.trim()
  end

  # In your config, you should define the SSO secret. We propose a syntax like:
  # config :clove, :clove_sso, secret: System.get_env("CLOVE_SSO_SECRET")
  defp sign_payload(payload) do
    secret = Application.fetch_env!(:your_app, :clove_sso) |> Keyword.fetch!(:secret)
    signer = Joken.Signer.create("HS256", secret)

    # Expiration is necessary to avoid infinite login
    exp = DateTime.utc_now() |> DateTime.to_unix() |> Kernel.+(60)
    payload = Map.put(payload, "exp", exp)

    {:ok, jwt, _claims} = Joken.generate_and_sign(%{}, payload, signer)

    jwt
  end
end
