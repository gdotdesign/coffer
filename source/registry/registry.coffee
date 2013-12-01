{Server}   = require 'ws'
Store      = require '../store'
RedisStore = require '../stores/redis'

class Registry extends Store
  constructor: (options, callback)->
    {@port,@store,@verbose} = options
    @server = new Server {port: @port}, -> callback()
    @server.on 'connection', @onConnection

  close: -> @server.close()

  onConnection: (ws)=>
    ws.on 'message', (data)=> @route ws, JSON.parse data
    ws.on 'close', -> ws.removeAllListeners()

  route: (ws, message)->
    @[message.type] message.data, (data)->
      ws.send JSON.stringify {id: message.id, data: data}

  get: (data, callback)->
    console.log "GET -  #{data.name}" if @verbose
    @store.get data.name, (component)=>
      callback if component is null then component else @serialize component

  set: (data, callback)->
    console.log "SET -  #{data.name}" if @verbose
    @store.set data.name, data.data, callback

  remove: (data, callback)->
    console.log "REMOVE -  #{data.name}" if @verbose
    @store.remove data.name, callback

  list: (data,callback)->
    console.log "LIST" if @verbose
    @store.list callback

module.exports = Registry
