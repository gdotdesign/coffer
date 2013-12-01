Registry        = require '../../source/registry/registry'
WebSocketStore  = require '../../source/stores/websocket'
MemoryStore     = require '../../source/stores/memory'
iStore        = require '../interfaces/store'
WebSocket       = require 'ws'

describe 'Redis / Registry / WebSocketStore (Integration)', ->
  before (done)->
    store = new MemoryStore =>
    @registry = new Registry {store: store, port: 23578}, =>
      @store = new WebSocketStore WebSocket, "ws://localhost:23578", -> done()

  after -> @registry.close()

  iStore.call @
