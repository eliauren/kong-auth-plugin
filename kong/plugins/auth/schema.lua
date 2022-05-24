local typedefs = require "kong.db.schema.typedefs"


local PLUGIN_NAME = "auth"


local schema = {
  name = PLUGIN_NAME,
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { authentication_url = { type = "string", required = true, default = "http://mockbin.org" }, },
          { request_header = typedefs.header_name { required = true, default = "Authorization" } }
        },
      },
    },
  },
}

return schema
