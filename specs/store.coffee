Store = require '../source/store'

describe 'Store', ->
  before ->
    @store = new Store

  it 'should have a list method', ->
    @store.should.have.property 'list'
    @store.list.should.be.an.instanceOf Function

  it 'should have a get method', ->
    @store.should.have.property 'get'
    @store.get.should.be.an.instanceOf Function

  it 'should have a set method', ->
    @store.should.have.property 'set'
    @store.set.should.be.an.instanceOf Function

  it 'should have a remove method', ->
    @store.should.have.property 'remove'
    @store.remove.should.be.an.instanceOf Function

  it 'should have serialize method', ->
    @store.should.have.property 'serialize'
    @store.serialize.should.be.an.instanceOf Function

  it 'should have deserialize method', ->
    @store.should.have.property 'serialize'
    @store.deserialize.should.be.an.instanceOf Function

  describe 'deserialize', ->
    it 'should return same object', ->
      obj = {}
      deserializedObj = @store.deserialize(obj)
      obj.should.be.exactly deserializedObj

    it 'should convert ports', ->
      obj = ports: {a: 'return "hello";', b: 'return "bye";'}
      deserializedObj = @store.deserialize(obj)
      deserializedObj.ports.a.should.be.instanceOf Function
      deserializedObj.ports.a().should.be.exactly "hello"
      deserializedObj.ports.b.should.be.instanceOf Function
      deserializedObj.ports.b().should.be.exactly "bye"

    it 'should convert events', ->
      obj = events: {a: 'return "hello";', b: 'return "bye";'}
      deserializedObj = @store.deserialize(obj)
      deserializedObj.events.a.should.be.instanceOf Function
      deserializedObj.events.a().should.be.exactly "hello"
      deserializedObj.events.b.should.be.instanceOf Function
      deserializedObj.events.b().should.be.exactly "bye"

  describe 'serialize', ->
    it 'should copy css property', ->
      obj = css: "test"
      serializedObj = @store.serialize(obj)
      serializedObj.should.have.property 'css'
      serializedObj.css.should.be.exactly obj.css

    it 'should copy css property as string', ->
      obj = css: 2
      serializedObj = @store.serialize(obj)
      serializedObj.should.have.property 'css'
      serializedObj.css.should.be.exactly "2"

    it 'should copy components property', ->
      obj = components: "test"
      serializedObj = @store.serialize(obj)
      serializedObj.should.have.property 'components'
      serializedObj.components.should.be.exactly obj.components

    it 'should work on empty object', ->
      obj = {}
      ( => @store.serialize(obj)).should.not.throw()

    it 'should convert ports', ->
      obj = ports: {a: (-> console.log("hello")), b: (-> console.log("bye"))}
      serializedObj = @store.serialize(obj)
      serializedObj.ports.a.should.be.exactly 'return console.log("hello");'
      serializedObj.ports.b.should.be.exactly 'return console.log("bye");'

    it 'should convert events', ->
      obj = events: {a: (-> console.log("hello")), b: (-> console.log("bye"))}
      serializedObj = @store.serialize(obj)
      serializedObj.events.a.should.be.exactly 'return console.log("hello");'
      serializedObj.events.b.should.be.exactly 'return console.log("bye");'
