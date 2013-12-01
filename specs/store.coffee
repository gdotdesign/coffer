Store = require '../source/store'

describe 'Store', ->
  before ->
    @store = new Store

  it 'should have a list method', ->
    @store.should.have.property 'list'
    @store.list.should.be.an.instanceOf Function
    (=> @store.list()).should.throw("Store::list not implemented!")

  it 'should have a get method', ->
    @store.should.have.property 'get'
    @store.get.should.be.an.instanceOf Function
    (=> @store.get()).should.throw("Store::get not implemented!")

  it 'should have a set method', ->
    @store.should.have.property 'set'
    @store.set.should.be.an.instanceOf Function
    (=> @store.set()).should.throw("Store::set not implemented!")

  it 'should have a remove method', ->
    @store.should.have.property 'remove'
    @store.remove.should.be.an.instanceOf Function
    (=> @store.remove()).should.throw("Store::remove not implemented!")

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

    it 'should convert properties', ->
      obj = properties: {a: 'return "hello";', b: 'return "bye";'}
      deserializedObj = @store.deserialize(obj)
      deserializedObj.properties.a.should.be.instanceOf Function
      deserializedObj.properties.a().should.be.exactly "hello"
      deserializedObj.properties.b.should.be.instanceOf Function
      deserializedObj.properties.b().should.be.exactly "bye"

    it 'should convert events', ->
      obj = events: {a: 'return "hello";', b: 'return "bye";'}
      deserializedObj = @store.deserialize(obj)
      deserializedObj.events.a.should.be.instanceOf Function
      deserializedObj.events.a.length.should.be.eql 2
      deserializedObj.events.a().should.be.exactly "hello"
      deserializedObj.events.b.should.be.instanceOf Function
      deserializedObj.events.b.length.should.be.eql 2
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

    it 'should convert properties', ->
      obj = properties: {a: (-> console.log('hello')), b: (-> console.log('bye'))}
      serializedObj = @store.serialize(obj)
      serializedObj.properties.a.indexOf("return console.log('hello');").should.not.be.exactly -1
      serializedObj.properties.b.indexOf("return console.log('bye');").should.not.be.exactly -1

    it 'should convert events', ->
      obj = events: {a: (-> console.log('hello')), b: (-> console.log('bye'))}
      serializedObj = @store.serialize(obj)
      serializedObj.events.a.indexOf("return console.log('hello');").should.not.be.exactly -1
      serializedObj.events.b.indexOf("return console.log('bye');").should.not.be.exactly -1
