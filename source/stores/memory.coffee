#= require ../store

class MemoryStore extends Store
  constructor: ->  @components = []

  get: (name, callback)->
    setTimeout =>
      return callback(null) unless @components[name]
      callback @deserialize JSON.parse @components[name]

  set: (name, component, callback)->
    setTimeout =>
      @components[name] = JSON.stringify @serialize component
      callback?()
