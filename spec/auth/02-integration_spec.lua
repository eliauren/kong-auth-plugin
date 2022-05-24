local helpers = require "spec.helpers"


local PLUGIN_NAME = "auth"


for _, strategy in helpers.all_strategies() do
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy == "off" and "postgres" or strategy, nil, { PLUGIN_NAME })

      -- Inject a test route. No need to create a service, there is a default
      -- service which will echo the request.
      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
      })

      local route2 = bp.routes:insert({
        hosts = { "test2.com" },
      })

      local route3 = bp.routes:insert({
        hosts = { "test3.com" },
      })

      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route1.id },
        config = {
          authentication_url = "http://mockbin.org/bin/f559dd15-ca80-4a29-889c-cb03aec5e644",
          request_header = "Authorization"
        },
      }

      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route2.id },
        config = {
          authentication_url = "https://mockbin.org/bin/b9bbe6ed-2163-4db5-af07-590ddb678639",
          request_header = "Authorization"
        },
      }

      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route3.id },
        config = {
          authentication_url = "https://mockbin.org/bad-url-value",
          request_header = "Authorization"
        },
      }

      -- start kong
      assert(helpers.start_kong({
        database   = strategy,
        nginx_conf = "spec/fixtures/custom_nginx.template",
        plugins = "bundled," .. PLUGIN_NAME,
        declarative_config = strategy == "off" and helpers.make_yaml_file() or nil,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)


    describe("request", function()
      it("gets a 'Authorization' header", function()
        local r = client:get("/request", {
          headers = {
            ["Host"] = "test1.com",
            ["Authorization"] = "authorization header value"
          }
        })

        assert.response(r).has.status(200)
        local header_value = assert.request(r).has.header("Authorization")
        assert.equal("authorization header value", header_value)
      end)
    end)

    describe("request", function()
      it("gets a 'Authorization' header", function()
        local r = client:get("/request", {
          headers = {
            ["Host"] = "test2.com",
            ["Authorization"] = "authorization header value"
          }
        })

        assert.response(r).has.status(401)
      end)
    end)

    describe("request", function()
      it("gets an incorrect 'Authorization' header", function()
        local r = client:get("/request", {
          headers = {
            ["Host"] = "test2.com",
            ["notgoodheader"] = "bad authorization header value"
          }
        })

        assert.response(r).has.status(401)
      end)
    end)

    describe("request", function()
      it("request a bad authentication url", function()
        local r = client:get("/request", {
          headers = {
            ["Host"] = "test3.com",
            ["Authorization"] = "Auth header value"
          }
        })

        assert.response(r).has.status(404)
      end)
    end)

  end)
end
