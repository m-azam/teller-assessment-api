defmodule Tellerapi.Hackerman.TellerBank do

  def f_token_gen(username, session_map) do
    f_token_spec = session_map["f-token-spec"]
    api_key = "HowManyGenServersDoesItTakeToCrackTheBank?"
    device_id = "YETWSWT3WPL3E6B7"
    session_map = Map.put(session_map, "api-key", api_key)
    session_map = Map.put(session_map, "device-id", device_id)
    session_map = Map.put(session_map, "username", username)
    session_map = Map.put(session_map, "last-request-id", session_map["f-request-id"])
    spec_decoded = :base64.decode(f_token_spec)
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
    f_token_elements = []
    f_token_elements = for param <- param_list do
        [session_map[param] | f_token_elements]
    end
    f_token_plain = Enum.join(f_token_elements, separator)

    hash = :crypto.hash(:sha256, f_token_plain)
    hash_encoded = :base64.encode(hash)
    String.trim_trailing(hash_encoded, "=")
  end

  def decrypt_account_number(username, enc_acc_number, enc_key, session_map) do
    # could be more generic but quick solution under time constraints
    method_enc = :base64.decode(enc_key)
    {:ok, method_map} = Poison.decode(method_enc)
    key_string = method_map["key"]
    key = :base64.decode(key_string)
    separator = ":"
    enc_acc_parts = String.split(enc_acc_number, separator)
    ct_string = Enum.at(enc_acc_parts, 0)
    iv_string = Enum.at(enc_acc_parts, 1)
    tag_string = Enum.at(enc_acc_parts, 2)
    ct = :base64.decode(ct_string)
    iv = :base64.decode(iv_string)
    tag = :base64.decode(tag_string)
    :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, ct, username, tag, false)
  end

end
