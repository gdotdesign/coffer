RedisStore = require '../../source/stores/redis'
iStore     = require '../interfaces/store'

describe 'RedisStore', ->
  before (done)->
    @store = new RedisStore 'http://localhost:6379', =>
      @store.client.del @store.prefix, -> done()

  iStore.call @
