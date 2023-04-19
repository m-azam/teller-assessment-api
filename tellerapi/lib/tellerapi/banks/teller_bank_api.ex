defmodule Tellerapi.Bank.TellerBankApi do

  def sign_in(user, pass) do
    request_headers = get_default_request_headers()

    url = "https://test.teller.engineering/signin"
    request_body_map = %{username: user, password: pass}
    {:ok, request_body} = Poison.encode(request_body_map)
    case HTTPoison.post(url, request_body, request_headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        # save session data to DB
        session_map = create_session_map(body, headers)
        IO.puts("session map:")
        IO.inspect(session_map)
        Tellerapi.Session.insert_session(user, session_map)
        case mfa(user, body, session_map) do
          {:mfa_accepted} -> true
          _ -> false
        end
      {:ok, %HTTPoison.Response{status_code: 401}} ->
        false
    end
  end

  def mfa(user, body, session_map) do
    mfa_request_url = "https://test.teller.engineering/signin/mfa"
    mfa_verify_url = "https://test.teller.engineering/signin/mfa/verify"
    request_headers = get_default_request_headers()
    request_headers = [{"r-token", session_map["r-token"]} | request_headers]
    f_token = Tellerapi.Hackerman.TellerBank.f_token_gen(user, session_map)
    request_headers = [{"f-token", f_token} | request_headers]
    request_headers = [{"teller-mission", "accepted!"} | request_headers]
    {:ok, body_decoded} = Poison.decode(body)
    mfa_device_id = Enum.at(body_decoded["data"]["devices"], 1)["id"]
    request_body_map = %{device_id: mfa_device_id}
    {:ok, request_body} = Poison.encode(request_body_map)
    IO.puts("----")
    IO.inspect(request_body)
    IO.puts("----")
    IO.puts("----")
    IO.inspect(request_headers)
    IO.puts("----")
    IO.puts("----")
    IO.inspect(f_token)
    IO.puts("----")
    case HTTPoison.post(mfa_request_url, request_body, request_headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        session_map = create_session_map(body, headers)
        Tellerapi.Session.insert_session(user, session_map)
        f_token = Tellerapi.Hackerman.TellerBank.f_token_gen(user, session_map)
        request_headers = get_default_request_headers()
        request_headers = [{"r-token", session_map["r-token"]} | request_headers]
        request_headers = [{"f-token", f_token} | request_headers]
        request_headers = [{"teller-mission", "accepted!"} | request_headers]
        request_body_map = %{code: "123456"} #mocked code for demo purposes
        {:ok, request_body} = Poison.encode(request_body_map)
        case HTTPoison.post(mfa_verify_url, request_body, request_headers) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
            session_map = create_session_map(body, headers)
            Tellerapi.Session.insert_session(user, session_map)
            IO.puts("----Success")
            IO.inspect(body)
            IO.puts("----")
            {:mfa_accepted}
        end
    end
  end

  def create_session_map(body, headers) do
    {:ok, body_map} = Poison.decode(body)
    header_params = ["f-request-id", "r-token", "f-token-spec"]
    session_map = Enum.reduce header_params, %{}, fn param, acc ->
      with key when is_tuple(key) <- List.keyfind(headers, param, 0) do
      Map.put(acc, param, elem(key, 1))
      end
    end
    # if Map.has_key?(body_map["data"], "enc_key") do
    #   session_map = Map.put(session_map, "enc_key", body_map["data"]["enc_key"])
    # end
    # if Map.has_key?(body_map["data"], "accounts") do
    #   session_map = Map.put(session_map, "accounts", body_map["data"]["accounts"])
    # end
    session_map
  end

  def get_default_request_headers() do
    # these are used in all request for Teller Bank, just a simple implementation for POC
    headers = [{"user-agent", "Teller Bank iOS 2.0"}, {"api-key", "HowManyGenServersDoesItTakeToCrackTheBank?"},{"device-id", "YETWSWT3WPL3E6B7"},{"content-type", "application/json"},{"accept", "application/json"}]
  end

end
