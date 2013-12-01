Store = require '../store.coffee'

# Stores components in Firebase
class FirebaseStore extends Store
  # Constructor
  constructor: (Firebase, options, callback)->
    throw new Error 'Must provide a callback!' unless callback instanceof Function

    @root = new Firebase("https://#{options.root}.firebaseio.com/#{options.node}/")

    info  = new Firebase("https://#{options.root}.firebaseio.com/.info/connected")
    info.on 'value', (snap)->
      if snap.val()
        callback()
        info.off('value')

  list: (callback)->
    @root.child('component_names').once 'value', (snap)=>
      return callback [] unless snap.val()
      callback Object.keys(snap.val())

  get: (name,callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @root.child('components/'+name).once 'value', (snap)=>
      return callback null unless snap.val()
      callback @deserialize snap.val()

  set: (name,component,callback)->
    throw new Error "Not enough arguments" if arguments.length < 2
    @root.child('component_names/'+name).set true, =>
      @root.child('components/'+name).set @serialize(component), (snap)=>
        callback()

  remove: (name, callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @root.child('component_names/'+name).set null, =>
      @root.child('components/'+name).set null, (snap)=>
        callback()

module.exports = FirebaseStore
