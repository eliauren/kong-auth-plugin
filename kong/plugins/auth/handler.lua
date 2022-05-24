local http = require "resty.http"

local plugin = {
  PRIORITY = 1000,
  VERSION = "0.1",
}

local function authenticate(plugin_conf, auth_header)
  local httpc = http:new()

  local result, error = httpc:request_uri(plugin_conf.authentication_url, {
    method = "GET",
      ssl_verify = false,
      headers = {
          ["Content-Type"] = "application/json",
          ["Authorization"] = auth_header }
  })

  if not result then
    kong.log.err("Failed to reach authentication url", err)
    return kong.response.exit(500)
  end

  if result.status ~= 200 then
    kong.log.err("Authentication url repsonse status : ", result.status)
    return kong.response.exit(result.status, result.body)
  end
end

function plugin:access(plugin_conf)
  local auth_header = kong.request.get_header(plugin_conf.request_header)

  if not auth_header then
    return kong.response.exit(401, { message = "Unauthorized" })
  end

  authenticate(plugin_conf, auth_header)
  kong.service.request.set_header(plugin_conf.request_header, auth_header)
end

return plugin
