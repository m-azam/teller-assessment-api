defmodule Tellerapi.Repo.Migrations.AddSessionsTable do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :username, :string
      add :session_data, :map

      timestamps()
    end
  end
end
