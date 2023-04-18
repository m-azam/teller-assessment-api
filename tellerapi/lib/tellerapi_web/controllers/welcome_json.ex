defmodule TellerapiWeb.WelcomeJSON do

  def index(%{message: message}) do
    %{message: "Hello #{message}!"}
  end
end
