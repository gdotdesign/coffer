WebSocketStore = require '../../source/stores/websocket'
iStore = require '../i-store'

class MockSocket
  addEventListener: (type,listener)->
    return if type is 'open'
    @listener = listener
    @store = {}
  send: (message)->
    message = JSON.parse message
    data = message.data
    ret  = switch message.type
      when "set"
        @store[data.name] = data.data
        false
      when "get"
        @store[data.name]
      when "list"
        Object.keys @store
      when "remove"
        delete @store[data.name]
        false
    if ret
      @listener data: JSON.stringify {id: message.id, data: ret}
    else
      @listener data: JSON.stringify {id: message.id}

describe 'WebSocketStore', ->
  before ->
    @store = new WebSocketStore MockSocket, '', ->

  iStore.call @
