Registry        = require '../../source/registry/registry'
WebSocketStore  = require '../../source/stores/websocket'
iStore 		    = require '../interfaces/store'
WebSocket       = require 'ws'

describe 'Registry / WebSocketStore (Integration)', ->
  before (done)->
    @registry = new Registry 'http://localhost:6379', 23578, =>
      @store = new WebSocketStore WebSocket, "ws://localhost:23578", =>
        @registry.store.client.del @registry.store.prefix, -> done()

  iStore.call @
