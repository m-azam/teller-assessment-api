defmodule Tellerapi.Hackerman.TellerBank do

  def f_token_gen(username, session_map) do
    f_token_spec = session_map["f-token-spec"]
    api_key = "HowManyGenServersDoesItTakeToCrackTheBank?"
    device_id = "YETWSWT3WPL3E6B7"
    session_map = Map.put(session_map, "api-key", api_key)
    session_map = Map.put(session_map, "device-id", device_id)
    session_map = Map.put(session_map, "username", username)
    session_map = Map.put(session_map, "last-request-id", session_map["f-request-id"])
    IO.puts("----")
    IO.inspect(f_token_spec)
    IO.puts("----")
    spec_decoded = :base64.decode(f_token_spec)
    IO.puts("----")
    IO.inspect(spec_decoded)
    IO.puts("----")
    pattern = Enum.at(Regex.scan(~r/\((.*?)\)/, spec_decoded) |> List.flatten, 1)
    separator = cond do
      length(String.split(pattern, "|")) == 3 -> "|"
      length(String.split(pattern, "--")) == 3 -> "--"
      length(String.split(pattern, "&")) == 3 -> "&"
      length(String.split(pattern, ":")) == 3 -> ":"
      length(String.split(pattern, "::")) == 3 -> "::"
      length(String.split(pattern, "+")) == 3 -> "+"
      length(String.split(pattern, "%")) == 3 -> "%"
      length(String.split(pattern, "$")) == 3 -> "$"
    end
    param_list = String.split(pattern, separator)
    IO.puts("----")
    IO.inspect(param_list)
    IO.puts("----")
    f_token_elements = []
    f_token_elements = for param <- param_list do
        [session_map[param] | f_token_elements]
    end
    f_token_plain = Enum.join(f_token_elements, separator)
    IO.puts("----")
    IO.inspect(f_token_plain)
    IO.puts("----")
    hash = :crypto.hash(:sha256, f_token_plain)
    hash_encoded = :base64.encode(hash)
    String.trim_trailing(hash_encoded, "=")
  end

end
