RedisStore = require '../../source/stores/redis'
iStore     = require '../interfaces/store'

describe 'RedisStore', ->
  before (done)->
    @store = new RedisStore =>
      @store.client.del @store.prefix, -> done()

  iStore.call @
