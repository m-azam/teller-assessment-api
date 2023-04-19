defmodule Tellerapi.BankInterface do

  def auth(username, password, bank) do
    case bank do
      "teller_bank" -> Tellerapi.Bank.TellerBankApi.sign_in(username, password)
      _ -> Tellerapi.Bank.TellerBankApi.sign_in(username, password)
    end
  end

end
