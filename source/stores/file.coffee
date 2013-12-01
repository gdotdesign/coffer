Store = require '../store.coffee'
fs    = require 'fs'
Path  = require 'path'
CoffeeScript = require 'coffee-script'

# Stores components in the filesystem
# This is a readonly store
class FileStore extends Store
  constructor: (options, callback)->
    {@base, @extension} = options
    setTimeout callback

  get: (name,callback)->
    path = Path.resolve @base, name+"."+@extension
    fs.exists path, (exists)=>
      console.log path, exists
      return callback null unless exists
      fs.readFile path, (err,data)=>
        data = CoffeeScript.compile(data.toString(),{bare: true}) if @extension is 'coffee'
        callback eval(data)

module.exports = FileStore
