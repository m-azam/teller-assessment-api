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
            {:mfa_accepted}
        end
    end
  end

  def get_accounts_info(username, session_map) do
    enc_key = session_map["enc_key"]
    account_id_list = []
    account_id_list = if Map.has_key?(session_map["accounts"], "checking") do
      for account <- session_map["accounts"]["checking"] do
        account["id"]
      end
    else
      account_id_list
    end
    request_headers = Tellerapi.Bank.TellerBankApi.get_default_request_headers()
    f_token = Tellerapi.Hackerman.TellerBank.f_token_gen(username, session_map)
    request_headers = [{"r-token", session_map["r-token"]} | request_headers]
    request_headers = [{"s-token", session_map["s-token"]} | request_headers]
    request_headers = [{"f-token", f_token} | request_headers]
    request_headers = [{"teller-mission", "accepted!"} | request_headers]
    account_list = for account_id <- account_id_list do
      case HTTPoison.get("https://test.teller.engineering/accounts/#{account_id}/balances", request_headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
          session_map = create_session_map(body, headers)
          Tellerapi.Session.insert_session(username, session_map)
          {:ok, response_map} = Poison.decode(body)
          account_number = get_decoded_account(username, account_id, enc_key, session_map)
          recent_transactions = response_map["last_transactions"]
          recent_transactions = get_all_transactions(username, account_id, recent_transactions)
          account_map = %{"available_balance" => response_map["available"],
          "ledger_balance" => response_map["available"], "account_numer" => account_number,
          "recent_transactions" => recent_transactions}
      end
    end
    account_list
  end

  def get_all_transactions(username, account_id, [head | transactions]) do
    all_trans = [head | transactions]
    prev_trans_id = Enum.at(transactions, -1)["id"]
    session_map = Tellerapi.Session.get_latest_session_by_username(username).session_data
    request_headers = Tellerapi.Bank.TellerBankApi.get_default_request_headers()
    f_token = Tellerapi.Hackerman.TellerBank.f_token_gen(username, session_map)
    request_headers = [{"r-token", session_map["r-token"]} | request_headers]
    request_headers = [{"s-token", session_map["s-token"]} | request_headers]
    request_headers = [{"f-token", f_token} | request_headers]
    request_headers = [{"teller-mission", "accepted!"} | request_headers]
    case HTTPoison.get("https://test.teller.engineering/accounts/#{account_id}/transactions?cursor=#{prev_trans_id}", request_headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        session_map = create_session_map("{\"empty\":\"empty\"}", headers)
        Tellerapi.Session.insert_session(username, session_map)
        {:ok, older_trans} = Poison.decode(body)
        [all_trans | get_all_transactions(username, account_id,older_trans)]
    end
  end

  def get_all_transactions(username, account_id, []) do
    []
  end

  def get_decoded_account(username, account_id, enc_key,session_map) do
    request_headers = Tellerapi.Bank.TellerBankApi.get_default_request_headers()
    f_token = Tellerapi.Hackerman.TellerBank.f_token_gen(username, session_map)
    request_headers = [{"r-token", session_map["r-token"]} | request_headers]
    request_headers = [{"s-token", session_map["s-token"]} | request_headers]
    request_headers = [{"f-token", f_token} | request_headers]
    request_headers = [{"teller-mission", "accepted!"} | request_headers]
    case HTTPoison.get("https://test.teller.engineering/accounts/#{account_id}/details", request_headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        session_map = create_session_map(body, headers)
        Tellerapi.Session.insert_session(username, session_map)
        {:ok, response_map} = Poison.decode(body)
        decoded_acc_number = Tellerapi.Hackerman.TellerBank.decrypt_account_number(username, response_map["number"], enc_key, session_map)
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
    s_token_tuple = List.keyfind(headers, "s-token", 0)
    session_map = if s_token_tuple != nil do
      Map.put(session_map, "s-token", elem(s_token_tuple, 1))
    else
      session_map
    end
    session_map = if Map.has_key?(body_map, "data") do
      if Map.has_key?(body_map["data"], "enc_key") do
        Map.put(session_map, "enc_key", body_map["data"]["enc_key"])
      else
        session_map
      end
    else
      session_map
    end
    session_map = if Map.has_key?(body_map, "data") do
      if Map.has_key?(body_map["data"], "accounts") do
        Map.put(session_map, "accounts", body_map["data"]["accounts"])
      else
        session_map
      end
    else
      session_map
    end
    session_map
  end

  def get_default_request_headers() do
    # these are used in all request for Teller Bank, just a simple implementation for POC
    headers = [{"user-agent", "Teller Bank iOS 2.0"}, {"api-key", "HowManyGenServersDoesItTakeToCrackTheBank?"},{"device-id", "YETWSWT3WPL3E6B7"},{"content-type", "application/json"},{"accept", "application/json"}]
  end

end
