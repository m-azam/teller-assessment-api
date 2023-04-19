defmodule Tellerapi.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :username, :string
      add :password, :string
      add :bank_name, :string

      timestamps()
    end
    create unique_index(:user, [:username])
  end
end
