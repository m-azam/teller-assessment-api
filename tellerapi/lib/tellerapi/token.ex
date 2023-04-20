defmodule Tellerapi.Token do
  @signing_salt "opportunity"
  # token valid for a year for demo purposes
  @token_age_secs 365 * 86_400

  @doc """
  Create token for given data
  """
  @spec sign(map()) :: binary()
  def sign(data) do
    Phoenix.Token.sign(TellerapiWeb.Endpoint, @signing_salt, data)
  end

  @doc """
  Verify given token by:
  - Verify token signature
  - Verify expiration time
  """
  @spec verify(String.t()) :: {:ok, any()} | {:error, :unauthenticated}
  def verify(token) do
    case Phoenix.Token.verify(TellerapiWeb.Endpoint, @signing_salt, Enum.at(token, 0), max_age: @token_age_secs) do
      {:ok, data} -> {:ok, data}
      _error -> {:error, :unauthenticated}
    end
  end
end
