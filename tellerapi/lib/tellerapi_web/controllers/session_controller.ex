defmodule TellerapiWeb.SessionController do
  use TellerapiWeb, :controller

  def enroll(conn, params) do
    username = params["username"]
    password = params["password"]
    bank_name = params["bank_name"]
    case Tellerapi.BankInterface.auth(username, password, bank_name) do
      true ->
        Tellerapi.Repo.get_or_insert(Tellerapi.User, %{username: username, password: password, bank_name: bank_name})
        json(conn, %{auth_token: Tellerapi.Token.sign(%{user_name: username, bank: bank_name})})
      false ->
        json(conn, %{error: "Invalid Bank account credentials"})
    end
  end
end
