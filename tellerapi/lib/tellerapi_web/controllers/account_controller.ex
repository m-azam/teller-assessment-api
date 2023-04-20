defmodule TellerapiWeb.AccountController do
  use TellerapiWeb, :controller

  def account(conn, params) do
    username = conn.assigns[:current_user]
    bank = conn.assigns[:bank]
    #
    #
    # Change next line of code to fetch and decode password from db
    #
    #
    #
    {:ok, user} = Tellerapi.Repo.get_or_insert(Tellerapi.User, %{username: username})
    Tellerapi.BankInterface.auth(username, user.password, bank)
    account_list = Tellerapi.BankInterface.fetch_account_details(username, bank)
    json(conn, %{accounts: account_list})
    # case sess <- Tellerapi.BankInterface.(username) do
    #   true ->

    #     json(conn, %{latest_session: Tellerapi.BankInterface.fetch_account_details()})
    #   false ->
    #     json(conn, %{error: ""})
    # end
  end
end
