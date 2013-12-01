Utils = require '../../source/utils'

module.exports = ->

  before (done)->
    component =
      css: 'test{}',
      events:
        test: ->
      properties:
        test: ->
    @store.set 'test', component, done

  describe 'constructor', ->
    it 'should throw error if there isnt a callback', ->
      constructor = Object.getPrototypeOf(@store).constructor
      (=> new constructor).should.throw('Must provide a callback!')

  describe 'get', ->
    it 'should throw error if there are not enough arguments', ->
      (=> @store.get()).should.throw('Not enough arguments')

    it "should return null the component doesn't exists", (done)->
      @store.get 'na', (args...)->
        args.should.include(null)
        done()

    it 'should return the component if it exists', (done)->
      @store.get 'test', (args...)->
        args.should.not.include(null)
        done()

    it 'should return valid component', (done)->
      @store.get 'test', (component)->
        Utils.validateComponent(component).should.be.true
        component.css.should.be.exactly 'test{}'
        component.events.test.should.be.instanceof Function
        component.properties.test.should.be.instanceof Function
        done()

  describe 'set', ->
    it 'should throw error if there are not enough arguments', ->
      (=> @store.set()).should.throw('Not enough arguments')

    it 'should call the callback', (done)->
      @store.set 'asd', {}, (args...)=>
        args.should.not.include(null)
        @store.remove 'asd', done

  describe 'list', ->
    it 'should return with the list of components', (done)->
      @store.list (components)->
        components.should.include 'test'
        done()

  describe 'remove', ->
    it 'should throw error if there are not enough arguments', ->
      (=> @store.remove()).should.throw('Not enough arguments')

    it 'should remove the component if it exists', (done)->
      @store.remove 'test', =>
        @store.list (components)->
          components.should.not.include 'test'
          done()

