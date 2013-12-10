Store = require '../store.coffee'
Redis = require 'redis'
URL   = require 'url'

# Stores components in redis
class RedisStore extends Store

  # Contstuctor
  #
  # @param [String] url The url to the Redis database
  # @param [Function] callback The callback to call when ready
  constructor: (url,callback)->
    throw new Error 'Must provide a callback!' unless callback instanceof Function
    @prefix = 'graphite'

    redisURL = URL.parse(url)
    @client = Redis.createClient(redisURL.port, redisURL.hostname, {no_ready_check: true})
    if redisURL.auth
      @client.auth(redisURL.auth.split(":")[1])

    @client.on 'ready', callback

  # Retrieves a component from this store
  #
  # @param [String] name The name of the component
  # @param [Function] callback The callback to run
  #
  # @return [Object] The component (in the callback)
  get: (name, callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @client.hget @prefix, name, (error, value)=>
      return callback(null) if error or not value
      callback @deserialize JSON.parse value

  # Removes a component from this store
  #
  # @param [String] name The name of the component
  # @param [Function] callback The callback to run
  remove: (name,callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @client.hdel @prefix, name, -> callback()

  # Stores a component from this store
  #
  # @param [String] name The name of the component
  # @param [Object] component The component
  # @param [Function] callback The callback to run
  set: (name,component,callback)->
    throw new Error "Not enough arguments" if arguments.length < 2
    @client.hset @prefix, name, JSON.stringify(@serialize(component)), -> callback()

  # Lists component names contained in this store
  #
  # @param [Function] callback The callback to run
  #
  # @return [Array] The names of the components (in the callback)
  list: (callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    @client.hkeys @prefix, (error, value)->
      callback if error then false else value

module.exports = RedisStore
