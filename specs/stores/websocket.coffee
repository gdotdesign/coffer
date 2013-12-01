WebSocketStore = require '../../source/stores/websocket'
MockSocket     = require '../interfaces/mock-socket'
iStore         = require '../interfaces/store'

describe 'WebSocketStore', ->
  before ->
    @store = new WebSocketStore MockSocket, '', ->

  iStore.call @
