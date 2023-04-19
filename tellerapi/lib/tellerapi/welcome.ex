defmodule Tellerapi.Welcome do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sample" do
    field :custome, :map
    field :title, :string
    field :views, :integer

    timestamps()
  end

  @doc false
  def changeset(welcome, attrs) do
    welcome
    |> cast(attrs, [:title, :views, :custome])
    |> validate_required([:title, :views, :custome])
  end
end
