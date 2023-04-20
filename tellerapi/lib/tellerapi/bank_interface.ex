defmodule Tellerapi.BankInterface do

  def auth(username, password, bank) do
    case bank do
      "teller_bank" -> Tellerapi.Bank.TellerBankApi.sign_in(username, password)
      _ -> Tellerapi.Bank.TellerBankApi.sign_in(username, password)
    end
  end

  def fetch_account_details(username, bank) do
    session_map = Tellerapi.Session.get_latest_session_by_username(username).session_data
    case bank do
      "teller_bank" -> Tellerapi.Bank.TellerBankApi.get_accounts_info(username, session_map)
      _ -> Tellerapi.Bank.TellerBankApi.get_accounts_info(username, session_map)
    end
  end

end
