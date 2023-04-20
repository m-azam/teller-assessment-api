defmodule TellerapiWeb.AccountController do
  use TellerapiWeb, :controller

  def account(conn, params) do
    username = conn.assigns[:current_user]
    bank = conn.assigns[:bank]
    {:ok, user} = Tellerapi.Repo.get_or_insert(Tellerapi.User, %{username: username})
    Tellerapi.BankInterface.auth(username, user.password, bank)
    account_list = Tellerapi.BankInterface.fetch_account_details(username, bank)
    json(conn, %{accounts: account_list})
  end
end
