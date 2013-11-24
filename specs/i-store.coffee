module.exports = ->

  before (done)->
    @store.set 'test', {}, done

  describe 'get', ->
    it 'should throw error if there are not enough arguments', ->
      (=> @store.get()).should.throw()

    it 'should return null if there are no components', (done)->
      @store.get 'na', (args...)->
        args.should.include(null)
        done()

    it 'should return the value passed for components', (done)->
      @store.get 'test', (args...)->
        args.should.not.include(null)
        done()

  describe 'set', ->
    it 'should throw error if there are not enough arguments', ->
      (=> @store.set()).should.throw()

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
      (=> @store.remove()).should.throw()

    it 'should remove the component', (done)->
      @store.remove 'test', =>
        @store.list (components)->
          components.should.not.include 'test'
          done()

