Store = require '../store.coffee'

# Stores components in Firebase
class FirebaseStore extends Store

  # Constructor
  #
  # @param [Firebase] Firebase The Firebase constructor
  # @param [Object] options The options for this instance
  constructor: (Firebase, options, callback)->
    throw new Error 'Must provide a callback!' unless callback instanceof Function

    @root = new Firebase("https://#{options.root}.firebaseio.com/#{options.node}/")

    info  = new Firebase("https://#{options.root}.firebaseio.com/.info/connected")
    info.on 'value', (snap)->
      if snap.val()
        callback()
        info.off('value')

  # Lists component names contained in this store
  #
  # @param [Function] callback The callback to run
  #
  # @return [Array] The names of the components (in the callback)
  list: (callback)->
    @root.child('component_names').once 'value', (snap)=>
      return callback [] unless snap.val()
      callback Object.keys(snap.val())

  # Retrieves a component from this store
  #
  # @param [String] name The name of the component
  # @param [Function] callback The callback to run
  #
  # @return [Object] The component (in the callback)
  get: (name,callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @root.child('components/'+name).once 'value', (snap)=>
      return callback null unless snap.val()
      callback @deserialize snap.val()

  # Stores a component from this store
  #
  # @param [String] name The name of the component
  # @param [Object] component The component
  # @param [Function] callback The callback to run
  set: (name,component,callback)->
    throw new Error "Not enough arguments" if arguments.length < 2
    @root.child('component_names/'+name).set true, =>
      @root.child('components/'+name).set @serialize(component), (snap)=>
        callback()

  # Removes a component from this store
  #
  # @param [String] name The name of the component
  # @param [Function] callback The callback to run
  remove: (name, callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @root.child('component_names/'+name).set null, =>
      @root.child('components/'+name).set null, (snap)=>
        callback()

module.exports = FirebaseStore
