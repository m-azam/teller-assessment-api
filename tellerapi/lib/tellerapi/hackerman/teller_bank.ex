defmodule Tellerapi.Hackerman.TellerBank do

  def f_token_gen(session_id) do
    # fetch from DB
    f_token_spec = "c2hhLTI1Ni1iNjQtbnAoYXBpLWtleXxkZXZpY2UtaWR8bGFzdC1yZXF1ZXN0LWlkKQ=="
    #
    spec_decoded = :base64.decode(f_token_spec)
    pattern = Enum.at(Regex.scan(~r/\((.*?)\)/, spec_decoded) |> List.flatten, 1)
    separator = cond do
      length(String.split(pattern, "|")) == 3 -> "|"
      length(String.split(pattern, "--")) == 3 -> "--"
      length(String.split(pattern, "&")) == 3 -> "&"
      length(String.split(pattern, ":")) == 3 -> ":"
      length(String.split(pattern, "::")) == 3 -> "::"
    end
    param_list = String.split(pattern, separator)
    f_token_elements = []
    for param <- param_list, do
      # fetch each param from session DB
      # prepend elements do not append

    end
    #reverse because elixir only has linked lists
    Enum.join(Enum.reverse(f_token_elements), separator)
  end

end
