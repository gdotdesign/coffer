Store = require '../store.coffee'

# WebSocket Store Adapter
class WebSocketStore extends Store

  # Generated unique identifier for transactions
  #
  # @return [String] The uid
  uid: -> ("0000" + (Math.random()*Math.pow(36,4) << 0).toString(36)).substr(-5)

  # Constructor
  #
  # @param [WebSocket] ws The WebSocket interface (WebSocket for browser / ws package for node)
  # @param [String] Path the path to connect to
  # @param [Function] callback The callback to call when ready
  constructor: (ws,path,callback)->
    super()
    throw new Error 'Must provide a callback!' unless callback instanceof Function
    @map = {}
    @socket = new ws(path)
    @socket.addEventListener 'message', @route
    @socket.addEventListener 'open', -> callback()
    setInterval (=> @query('keepalive')), 2000

  isCached: (name, callback)->
    return callback false unless @cache[name]
    @query 'isCached', {name: name}, callback

  # Closes the websocket connection
  close: -> @socket.close()

  # Handles massages
  #
  # @param [Event] e The event
  # @private
  route: (e)=>
    {id,data} = JSON.parse e.data
    @map[id]? data
    delete @map[id]

  # Sends a constructed message trough the websocket
  #
  # @param [String] type The type of the massage
  # @param [Object] data The data to send
  # @param [Function] callback The callback to call
  # @private
  query: (type,data,callback)->
    id = @uid()
    @map[id] = callback if callback
    @socket.send JSON.stringify {id: id, type: type, data: data}

  # Lists component names contained in this store
  #
  # @param [Function] callback The callback to run
  #
  # @return [Array] The names of the components (in the callback)
  list: (callback)->
    @query 'list', {}, callback

  # Retries a component from this store
  #
  # @param [String] name The name of the component
  # @param [Function] callback The callback to run
  #
  # @return [Object] The component (in the callback)
  get: (name,callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    super name, callback, (cb)=>
      @query 'get', { name: name }, (data)=>
        return cb(null) unless data
        cb @deserialize data

  # Stores a component from this store
  #
  # @param [String] name The name of the component
  # @param [Object] component The component
  # @param [Function] callback The callback to run
  set: (name,component,callback)->
    throw new Error "Not enough arguments" if arguments.length < 2
    @query 'set', { name: name, data: @serialize component }, (data)=>
      callback?()

  # Removes a component from this store
  #
  # @param [String] name The name of the component
  # @param [Function] callback The callback to run
  remove: (name,callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @query 'remove', {name: name}, callback

module.exports = WebSocketStore
