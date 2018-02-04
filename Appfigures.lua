WebBanking {
  version = 1.01,
  description = "Access your app sales in Appfigures",
  services = { "Appfigures" }
}

local baseURL = "http://api.appfigures.com/v2/"

local accountEmail
local accountPassword
local clientKey

local httpAuthCredentials

local connection = Connection()

function SupportsBank(protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Appfigures"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  accountEmail = username
  clientKey = username2
  accountPassword = password

  -- This will be used for HTTP Basic Authentication
  httpAuthCredentials = MM.base64(username .. ":" .. accountPassword)
end

function ListAccounts (knownAccounts)

  local currency = requestCurrency()

  local requestedProducts = requestProducts()
  local productAccounts = {}

  for k, product in pairs(requestedProducts) do
    productAccounts[#productAccounts + 1] = {
      name = product["name"],
      accountNumber = product["id"],
      currency = currency,
      portfolio = false,
      bankCode = product["store"],
      type = "AccountTypeOther"
    }
  end
  return productAccounts
end

function RefreshAccount (account, since)

  local formattedDate = MM.localizeDate("yyyy-MM-dd", since)
  local requestedTransactions = requestTransactions(account["accountNumber"], formattedDate)

  local transactions = {}

  for k, transaction in pairs(requestedTransactions) do

    local name = ""
    name = name .. transaction["net_downloads"] .. " download" .. plural(transaction["net_downloads"])

    local purpose = ""

    purpose = purpose .. transaction["updates"] .. " update" .. plural(transaction["updates"])

    if transaction["gifts"] > 0 then
      purpose = purpose .. " · "
      purpose = purpose .. transaction["gifts"] .. " gift" .. plural(transaction["gifts"])
    end

    if transaction["edu_downloads"] > 0 then
      purpose = purpose .. " · "
      purpose = purpose .. transaction["edu_downloads"] .. " educational"
    end

    if transaction["promos"] > 0 then
      purpose = purpose .. " · "
      purpose = purpose .. transaction["promos"] .. " promo" .. plural(transaction["promos"])
    end

    local transactionDate = isoToPosixDate(transaction["date"])

    if tonumber(transaction["revenue"]) ~= 0 or tonumber(transaction["returns_amount"]) ~= 0 then
      transactions[#transactions + 1] = {
        bookingDate = transactionDate,
        name = name,
        purpose = purpose,
        -- Add the returns before subtracting them below. Not sure if this is the best way
        -- to handle this, but at least it should keep the totals consistent.
        amount = transaction["revenue"] + transaction["returns_amount"]
      }
    end

    if transaction["returns"] > 0 then
      transactions[#transactions + 1] = {
        bookingDate = transactionDate,
        name = transaction["returns"] .. " return"  .. plural(transaction["returns"]),
        amount = -1 * tonumber(transaction["returns_amount"])
      }
    end
  end

  local requestedTotal = requestTotal(account["accountNumber"])
  local balance = requestedTotal["revenue"]

  return { balance = balance, transactions = transactions }

end

function EndSession()
  -- Do nothing.
end

-- Networking

function requestCurrency()
  local currency = "USD" -- Fallback

  local url = baseURL .. "users/" .. accountEmail

  local headers = {}
  headers["Authorization"] = "Basic " .. httpAuthCredentials
  headers["X-Client-Key"] = clientKey

  local response = connection:request("GET", url, {}, nil, headers)

  local json = JSON(response)
  local userInfo = json:dictionary()

  if userInfo ~= nil then
    print("Please make sure that this API client has sufficient privileges to access the user account information.")
    print("Otherwise the initial currency may be wrong.")
    if userInfo["currency"] ~= nil then
      currency = userInfo["currency"]
      print("got currency " .. currency)
    end
  end

  return currency
end

function requestProducts()
  local url = baseURL .. "products/mine/"

  local headers = {}
  headers["Authorization"] = "Basic " .. httpAuthCredentials
  headers["X-Client-Key"] = clientKey

  local response = connection:request("GET", url, {}, nil, headers)
  local json = JSON(response)

  return json:dictionary()
end


function requestTransactions(accountID, startDate)
  local url = baseURL .. "reports/sales/?group_by=date&include_inapps=true&startdate=" .. startDate .. "&products=" .. accountID

  local headers = {}
  headers["Authorization"] = "Basic " .. httpAuthCredentials
  headers["X-Client-Key"] = clientKey

  local response = connection:request("GET", url, {}, nil, headers)
  local json = JSON(response)

  return json:dictionary()
end

function requestTotal(accountID)
  local url = baseURL .. "reports/sales/?products=" .. accountID

  local headers = {}
  headers["Authorization"] = "Basic " .. httpAuthCredentials
  headers["X-Client-Key"] = clientKey

  local response = connection:request("GET", url, {}, nil, headers)
  local json = JSON(response)

  return json:dictionary()
end

-- Helpers

function isoToPosixDate (s)
    local y, m, d = string.match(s, "(%d%d%d%d)-(%d%d)-(%d%d)")
    return os.time { year = y, month = m, day = d }
end

function plural(i)
  -- Append an s if the number i is not equal to 1
  local s = ""
  if i ~= 1 then
    s = "s"
  end
  return s
end
