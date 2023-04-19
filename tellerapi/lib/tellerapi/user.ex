defmodule Tellerapi.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user" do
    field :username, :string
    field :password, :string
    field :bank_name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :bank_name])
    |> validate_required([:username, :password, :bank_name])
    |> unique_constraint(:username)
  end
end
