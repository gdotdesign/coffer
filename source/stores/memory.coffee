Store = require '../store.coffee'

class MemoryStore extends Store
  constructor: ->
    @db = []

  list: (callback)->
    callback? Object.keys(@db)

  get: (name, callback)->
    throw "Not enough arguments" if arguments.length is 0
    return callback(null) unless @db[name]
    callback? @db[name]

  set: (name, component, callback)->
    throw "Not enough arguments" if arguments.length < 2
    @db[name] = component
    callback?()

  remove: (name, callback)->
    throw "Not enough arguments" if arguments.length is 0
    delete @db[name]
    callback?()

module.exports = MemoryStore
