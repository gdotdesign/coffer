MemoryStore = require '../../source/stores/memory'
iStore      = require '../interfaces/store'

describe 'MemoryStore', ->
  before (done)->
    @store = new MemoryStore done

  it 'should have a db property', ->
    @store.should.have.property 'db'
    @store.db.should.be.instanceOf Object

  iStore.call @
