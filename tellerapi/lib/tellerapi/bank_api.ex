defmodule Tellerapi.BankApi do

  def auth(user, pass) do
    headers = ["user-agent": "Teller Bank iOS 2.0", "api-key": "HowManyGenServersDoesItTakeToCrackTheBank?","device-id": "YETWSWT3WPL3E6B7","content-type": "application/json","accept": "application/json"]

    url = "https://test.teller.engineering/signin"
    body_map = %{username: user, password: pass}
    body = Poison.encode(body_map)
    HTTPoison.post(url, body, headers)
  end

  def mfa(data) do
    headers = [
      "f-request-id", "req_e6orfmqip3nz6z5kxhklsumjdv64t6puj4v7cly",
      "f-token-spec",
       "c2hhLTI1Ni1iNjQtbnAoYXBpLWtleXxkZXZpY2UtaWR8bGFzdC1yZXF1ZXN0LWlkKQ==",
      "r-token",
       "QTEyOEdDTQ.17b8lr8u9snUHKYVdis3AsySF68tj5WhXQP0via7yUA_vFssfwsZ6DXduXs.jgEJNaBVCOuKdLve.O9sZNe8kUIiUvAvAd7ol0uNQjG59EQtakD8YBtg9knFOosgVwHsmh57wfctcvxHmE2y3wKnwwpfcQIPGc6bYb8LdORqUVi9f3uU_16ovjdKJQdyue_WPZ0bfKZI_Rc1rS-Q4LuNDYwaUbFr_UV95fiqO5Z-NLWprBN-q_FBhKlu58jqS2kIkCjTn0iRyShsXOc_yMyKzSaTdDeSEaSqUwuQaRcw.YxroayjCq1iGWNyFJNupGw",
      "teller-mission", "https://blog.teller.io/2021/06/21/our-mission.html"
    ]

  end

end
