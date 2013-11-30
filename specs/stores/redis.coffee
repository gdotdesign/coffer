RedisStore = require '../../source/stores/redis'
iStore = require '../i-store'

describe 'RedisStore', ->
  before ->
    @store = new RedisStore

  iStore.call @
