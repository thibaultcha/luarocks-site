import request, request_as, do_upload_as from require "spec.helpers"
import truncate_tables from require "lapis.spec.db"
import generate_token from require "lapis.csrf"

factory = require "spec.factory"

import
  load_test_server
  close_test_server
  request
  from require "lapis.spec.server"

import
  Users
  ApiKeys

  Manifests
  ManifestModules
  Modules
  Versions
  Rocks
  from require "models"

describe "application.api", ->
  local root, user

  setup ->
    load_test_server!

  teardown ->
    close_test_server!

  before_each ->
    truncate_tables Users, ApiKeys, Manifests, ManifestModules, Modules,
      Versions, Rocks

    root = Manifests\create "root", true
    user = Users\create "leafo", "leafo", "leafo@example.com"

  it "should create an api key", ->
    status, body = request_as user, "/api_keys/new", {
      post: {}
    }
    assert.same 302, status
    assert.same 1, #ApiKeys\select!


  it "should get tool version", ->
    status, res = request_as nil, "/api/tool_version", {
      expect: "json"
    }

    assert.same 200, status
    config = require"lapis.config".get!
    assert.same {version: config.tool_version}, res

  describe "with key", ->
    local key, prefix

    api_request = (path, opts={}) ->
      opts.expect = "json" unless opts.expect != nil
      status, res = request "#{prefix}#{path}", opts
      assert.same 200, status

      res

    before_each ->
      key = factory.ApiKeys user_id: user.id
      prefix = "/api/1/#{key.key}"

    it "should get key status", ->
      res = api_request "/status"
      assert.same user.id, res.user_id

    it "should check nonexistent rockspec", ->
      res = api_request "/check_rockspec", {
        get: {
          package: "hello"
          version: "1-1"
        }
      }

      assert.same {}, res

