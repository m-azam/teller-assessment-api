defmodule Tellerapi.Repo.Migrations.CreateSample do
  use Ecto.Migration

  def change do
    create table(:sample) do
      add :title, :string
      add :views, :integer
      add :custome, :map

      timestamps()
    end
  end
end
