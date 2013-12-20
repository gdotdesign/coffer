{Server}   = require 'ws'
Store      = require '../store'
RedisStore = require '../stores/redis'

# Registry for components
#
# Creates a WebSocket server for managing components.
# Any of the Store classes can be used as backend.
class Registry extends Store

  # Constructor
  #
  # @param [Object] Options The options for this registry
  # @param [Function] Callback The callback to call when ready
  constructor: (options, callback)->
    {@port,@store,@verbose} = options
    @server = new Server {port: @port}, -> callback()
    @server.on 'connection', @onConnection

  # Closes the websocket server and the registry
  close: -> @server.close()

  # Connection handler
  #
  # @param [WebSocket] ws The client WebSocket
  # @private
  onConnection: (ws)=>
    ws.on 'message', (data)=> @route ws, JSON.parse data
    ws.on 'close', -> ws.removeAllListeners()

  # Handles the routing of messages
  #
  # @param [WebSocket] ws The client WebSocket
  # @param [Object] message The message event
  # @private
  route: (ws, message)->
    return if message.type is 'keepalive'
    @[message.type] message.data, (data)->
      ws.send JSON.stringify {id: message.id, data: data}

  isCached: (data, callback)->
    @store.isCached data.name, data.time, callback

  # Retrieves a component from this registry
  #
  # @param [String] name The name of the component
  # @param [Function] callback The callback to run
  #
  # @return [Object] The component (in the callback)
  get: (data, callback)->
    console.log "GET -  #{data.name}" if @verbose
    @store.get data.name, (component)=>
      callback if component is null then component else @serialize component

  # Stores a component from this registry
  #
  # @param [String] name The name of the component
  # @param [Object] component The component
  # @param [Function] callback The callback to run
  set: (data, callback)->
    console.log "SET -  #{data.name}" if @verbose
    @store.set data.name, data.data, callback

  # Removes a component from this registry
  #
  # @param [String] name The name of the component
  # @param [Function] callback The callback to run
  remove: (data, callback)->
    console.log "REMOVE -  #{data.name}" if @verbose
    @store.remove data.name, callback

  # Lists component names contained in this registry
  #
  # @param [Function] callback The callback to run
  #
  # @return [Array] The names of the components (in the callback)
  list: (data,callback)->
    console.log "LIST" if @verbose
    @store.list callback

module.exports = Registry
