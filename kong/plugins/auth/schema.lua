local typedefs = require "kong.db.schema.typedefs"


local PLUGIN_NAME = "auth"


local schema = {
  name = PLUGIN_NAME,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
          { authentication_url = { type = "string", required = true, default = "http://mockbin.org/bin/19e532e1-0dde-4293-9da7-a66c3fc308e6" }, },
          { request_header = typedefs.header_name { required = true, default = "Hello-World" } }
        },
      },
    },
  },
}

return schema
