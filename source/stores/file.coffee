Store        = require '../store.coffee'
Fs           = require 'fs'
Path         = require 'path'
CoffeeScript = require 'coffee-script'

# Stores components in the filesystem
# This is a readonly store
class FileStore extends Store

  # Constructor
  #
  # @param [Object] options The options for this instance
  # @param [Function] callback The callback to call when ready
  constructor: (options, callback)->
    throw new Error 'Must provide a callback!' unless callback instanceof Function

    {@base, @extension} = options
    @extension ?= 'js'
    setTimeout callback

  # Get path based on base directory
  #
  # @param [String] name The name of the component
  #
  # @return [String] The path of the component
  getPath: (name)->
    path = Path.resolve @base, name+"."+@extension

  # Retrieves a component from this store
  #
  # @param [String] name The name of the component
  # @param [Function] callback The callback to run
  #
  # @return [Object] The component (in the callback)
  get: (name,callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    path = @getPath name
    Fs.exists path, (exists)=>
      return callback null unless exists
      Fs.readFile path, (err,data)=>
        data = data.toString()
        if @extension is 'coffee'
          try
            data = CoffeeScript.compile(data,{bare: true})
            return callback eval(data)
        else
          try
            return callback eval(data)
        callback @deserialize JSON.parse data

  # Stores a component from this store
  #
  # @param [String] name The name of the component
  # @param [Object] component The component
  # @param [Function] callback The callback to run
  set: (name,component,callback)->
    throw new Error "Not enough arguments" if arguments.length < 2
    path = @getPath name
    Fs.writeFile path, JSON.stringify(@serialize(component)), -> callback()

  # Removes a component from this store
  #
  # @param [String] name The name of the component
  # @param [Function] callback The callback to run
  remove: (name,callback)->
    throw new Error "Not enough arguments" if arguments.length is 0
    path = @getPath name
    Fs.exists path, (exists)=>
      return callback null unless exists
      Fs.unlink path, -> callback()

  # Lists component names contained in this store
  #
  # @param [Function] callback The callback to run
  #
  # @return [Array] The names of the components (in the callback)
  list: (callback)->
    Fs.readdir @base, (err,files)->
      callback files.map (name)-> Path.basename name, Path.extname name

module.exports = FileStore
