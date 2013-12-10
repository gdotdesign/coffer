FileStore = require './source/stores/file'
graphite  = require './source/graphite'
WebSocket = require 'ws'

graphite.buildClient (code)->
  console.log(code)
