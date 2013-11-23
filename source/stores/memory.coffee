Store = require '../store.coffee'

class MemoryStore extends Store
  constructor: ->  @components = []

  list: (callback)->
  	setTimeout =>
  		callback? Object.keys(@components)

  get: (name, callback)->
    setTimeout =>
      return callback(null) unless @components[name]
      callback? @components[name]

  set: (name, component, callback)->
    setTimeout =>
      @components[name] = component
      callback?()

  remove: (name, callback)->
  	setTimeout =>
  		delete @components[name]
  		callback?()

module.exports = MemoryStore
