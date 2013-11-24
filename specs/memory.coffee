MemoryStore = require '../source/stores/memory'
iStore = require './i-store'

describe 'MemoryStore', ->
  before ->
    @store = new MemoryStore

  it 'should have a db property', ->
  	@store.should.have.property 'db'
  	@store.db.should.be.instanceOf Object

  iStore.call @
