FileStore = require './source/stores/file'
graphite = require './source/graphite'
WebSocket       = require 'ws'

store = new FileStore {base: __dirname, extension: 'coffee'}, ->

  graphite.build store,'test', (bundle)->
    console.log bundle
