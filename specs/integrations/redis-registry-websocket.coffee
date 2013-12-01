Registry        = require '../../source/registry/registry'
WebSocketStore  = require '../../source/stores/websocket'
RedisStore      = require '../../source/stores/redis'
iStore          = require '../interfaces/store'
WebSocket       = require 'ws'

describe 'Redis / Registry / WebSocketStore (Integration)', ->
  before (done)->
    store = new RedisStore 'http://localhost:6379', =>
    @registry = new Registry {store: store, port: 23578}, =>
      @store = new WebSocketStore WebSocket, "ws://localhost:23578", =>
        @registry.store.client.del @registry.store.prefix, -> done()

  after -> @registry.close()

  iStore.call @
