# Hello,

Let's begin with how to test, then I will explain the approach.

There are 3 endpoints in the API:

### 1) Welcome:

`GET http://localhost:4000/api/` will give you a welcome message stating everything is working as it should.

### 2) Enroll:

`POST http://localhost:4000/api/enroll`

`{
    "username": "user",
    "password": "pass",
    "bank_name": "teller_bank"
}`

this will return:

`{
    "auth_token": "SFMyNTY.g2gDd.......ERk8vX4QybpR1plHeppWUTxFo"
}`

### 3) Accounts:

`GET http://localhost:4000/api/accounts`
`Headers`: `{"authorization", "the auth_token from enroll here"}`

returns:
`{
    "accounts": [
        {
            "account_numer": "........",
            "available_balance": .....,
            "ledger_balance": ......,
            "recent_transactions": [
                [.....]
}`




With that out of the way, let's discuss the approach:

### The Tech:
- Elixir as required is used with Phoenix framework.
- The default DB of postgres was kept.

### API endpoints:
- Only 2 endpoints are available to keep things simple due to both time constraints and ease of use.
- Token auth is being utilized to identify the user 
- For demo purposes the password is being stored to avoid re-auth problems as requested.
- The enroll api will complete sign-in and mfa steps.
- The accounts api will fetch balance, details and transactions.

### The Design:
- Addition of other banks is considerd in the approach.
- The Controllers are agnostic of the bank api interaction.
- Controllers only speak to the Bank Interface which in turn knows which module to pick.
- Each bank api will have a API module and a `hackerman` module.
- The API module is responsible to encapsulate the interaction while providing contextual data to each request.
- The `hackerman` module is responsible for breaking any encryption or generating any special tokens.
- The `session_data` as I have called it stores the header and body parameters that are relevant to the particular bank API.
- Which brings us to the DB design:
  - User DB is self explanatory. Note: I understand passwords are generally not stored, this is only for demo purposes.
  - session DB stores the username identifier and the session_data `jsonb` which allows storage of "custom" data depending on the bank api's needs.
- This generic design, limits specialized code to API module and `hackerman` module and specialized data to the session_data field.
- The aim of this design is to demonstrate my ability to account for future additions.


I really enjoyed working on this assessment! -Azam



