Store      = require '../store.coffee'
Waterline  = require 'waterline'
Collection = Waterline.Collection.extend({adapter: 'store',schema:false})

# WebSocket Store Adapter
class WaterlineStore extends Store

  # Constructor
  #
  # @param [WebSocket] ws The WebSocket interface (WebSocket for browser / ws package for node)
  # @param [String] Path the path to connect to
  # @param [Function] callback The callback to call when ready
  constructor: (adapter,callback)->
    throw new Error 'Must provide a callback!' unless callback instanceof Function
    new Collection tableName: 'components', adapters: {store: adapter}, (err,@collection)=>
      setTimeout => callback()

  # Lists component names contained in this store
  #
  # @param [Function] callback The callback to run
  #
  # @return [Array] The names of the components (in the callback)
  list: (callback)->
    @collection.find().then (items)->
      callback items.map (item)-> item.name

  # Retries a component from this store
  #
  # @param [String] name The name of the component
  # @param [Function] callback The callback to run
  #
  # @return [Object] The component (in the callback)
  get: (name,callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @collection.findOne({name: name}).then (component)=>
      return callback null unless component
      delete component.name
      callback @deserialize component

  # Stores a component from this store
  #
  # @param [String] name The name of the component
  # @param [Object] component The component
  # @param [Function] callback The callback to run
  set: (name,component,callback)->
    throw new Error "Not enough arguments" if arguments.length < 2
    component = @serialize component
    @collection.findOne {name: name}, (err,comp)=>
      unless comp
        component.name = name
        @collection.create(component).then -> callback()
      else
        @collection.update({name: name},component).then -> callback()

  # Removes a component from this store
  #
  # @param [String] name The name of the component
  # @param [Function] callback The callback to run
  remove: (name,callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @collection.destroy({name: name}).then (component)=> callback?()

module.exports = WaterlineStore
