Store = require '../store.coffee'
Redis = require 'redis'

# Stores components in redis
class RedisStore extends Store
  constructor: ->
    @prefix = 'graphite'
    @client = Redis.createClient()

  get: (name, callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @client.hget @prefix, name, (error, value)->
      callback if error then false else JSON.parse value

  remove: (name,callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @client.hdel @prefix, name, -> callback()

  set: (name,component,callback)->
    throw new Error "Not enough arguments" if arguments.length < 2
    @client.hset @prefix, name, JSON.stringify(component), -> callback()

  list: (callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @client.hkeys @prefix, (error, value)->
      callback if error then false else value

module.exports = RedisStore
