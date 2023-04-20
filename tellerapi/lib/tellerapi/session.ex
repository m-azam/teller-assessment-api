defmodule Tellerapi.Session do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "sessions" do
    field :username, :string
    field :session_data, :map

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:username, :session_data])
    |> validate_required([:username, :session_data])
  end

  def insert_session(username, session_map) do
    Tellerapi.Repo.insert(%Tellerapi.Session{username: username, session_data: session_map})
  end

  def get_latest_session_by_username(username) do
    from(s in Tellerapi.Session, where: s.username == ^username,  limit: 1, order_by: [desc: s.id]) |> Tellerapi.Repo.one
  end
end
