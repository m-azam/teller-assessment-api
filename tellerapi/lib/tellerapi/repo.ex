defmodule Tellerapi.Repo do
  use Ecto.Repo,
    otp_app: :tellerapi,
    adapter: Ecto.Adapters.Postgres
end
