WaterlineStore = require '../../source/stores/waterline'
MemoryAdapter  = require 'sails-memory'
iStore         = require '../interfaces/store'

describe 'WaterlineStore', ->
  before (done)->
    @store = new WaterlineStore MemoryAdapter, done

  iStore.call @
