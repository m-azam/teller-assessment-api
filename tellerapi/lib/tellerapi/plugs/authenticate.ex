defmodule Tellerapi.Plug.Authenticate do
  import Plug.Conn
  require Logger

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, data} <- MyApp.Token.verify(token) do
      conn
      |> assign(:current_user, MyApp.Account.get_user(data.user_id))
    else
      error ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.put_view(MyAppWeb.ErrorView)
        |> Phoenix.Controller.render(:"401")
        |> halt()
    end
  end
end
