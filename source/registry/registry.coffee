{Server}   = require 'ws'
RedisStore = require '../stores/redis'

module.exports = class Registry
  constructor: (callback)->
    @store  = new RedisStore
    @server = new Server {port: 23578}, ->
      console.log "Graphite registry running on 23578..."
      callback()

    @server.on 'connection', @onConnection

  onConnection: (ws)=>
    ws.on 'message', (data)=> @route ws, JSON.parse data
    ws.on 'close', -> ws.removeAllListeners()

  route: (ws, message)->
    @[message.type] message.data, (data)->
      ws.send JSON.stringify {id: message.id, data: data}

  get: (data, callback)->
    @store.get data.name, callback

  set: (data, callback)->
    @store.set data.name, data.data, callback

  remove: (data, callback)->
    @store.remove data.name, callback

  list: (data,callback)->
    @store.list callback
