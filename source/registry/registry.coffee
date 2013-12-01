{Server}   = require 'ws'
Store      = require '../store'
RedisStore = require '../stores/redis'

class Registry extends Store
  constructor: (callback)->
    @store = new RedisStore =>
      @server = new Server {port: 23578}, ->
        callback()
      @server.on 'connection', @onConnection

  onConnection: (ws)=>
    ws.on 'message', (data)=> @route ws, JSON.parse data
    ws.on 'close', -> ws.removeAllListeners()

  route: (ws, message)->
    @[message.type] message.data, (data)->
      ws.send JSON.stringify {id: message.id, data: data}

  get: (data, callback)->
    @store.get data.name, (component)=>
      callback if component is null then component else @serialize component

  set: (data, callback)->
    @store.set data.name, data.data, callback

  remove: (data, callback)->
    @store.remove data.name, callback

  list: (data,callback)->
    @store.list callback

module.exports = Registry
