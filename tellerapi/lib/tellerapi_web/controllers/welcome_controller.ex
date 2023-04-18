defmodule TellerapiWeb.WelcomeController do
  use TellerapiWeb, :controller

  def index(conn, _params) do
    render(conn, :index, message: "World")
  end
end
