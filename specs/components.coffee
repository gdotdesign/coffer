Components = require '../source/components'

if process
  jsdom = require 'jsdom'
  Components.document = jsdom.jsdom("<html></html>")
  Element = jsdom.level(1, "core").Element
else
  Components.document = document

describe 'Components', ->

  describe 'register', ->
    it 'should throw error for invalid tagname', ->
      (-> Components.register '$test').should.throw()

    it 'should call store register', (done)->
      data = {}
      Components.register 'test', data, ->
        Components.store.components.should.have.property 'test'
        Components.store.components.test.should.be.exactly data
        delete Components.store.components.test
        done()

  describe 'create', ->
    before (done)->
      Components.register 'btn', {
        css: "btn { display: block }"
      }, =>
        Components.register 'login', {
          css: "login { background: linear-gradient(#fff,#000) }"
          components:
            Button: {type: 'btn', position: 1}
            Button2: {type: 'btn', position: 0}
          properties:
            username: (value)->
              @setAttribute 'username', value
          events:
            ready: -> @_ready = true
            test: -> @_test = true
        }, =>
          Components.create 'login', (@component)=>
            done()

    it 'should throw error for invalid tagname', ->
      (-> Components.create '$test').should.throw()

    it 'should return with element when there is no component', (done)->
      Components.create 'test', (component)->
        component.should.be.instanceOf Element
        done()

    it 'should add fireEvent and matchesSelector to the element',->
      @component.should.have.property 'matchesSelector'
      @component.should.have.property 'fireEvent'

    it 'should add properties to the element', ->
      desc = Object.getOwnPropertyDescriptor @component, 'username'
      desc.should.not.be.null
      desc.should.have.property 'get'
      desc.should.have.property 'set'
      desc.should.have.property 'enumerable'
      desc.enumerable.should.be.true

    it 'should call provided function when setting port', ->
      @component.username = "gdot"
      @component.getAttribute('username').should.be.exactly 'gdot'

    it 'should set data store entriy for property', ->
      @component.username = "gdot1"
      @component._data.should.have.property 'username'
      @component._data.username.should.be.exactly 'gdot1'

    it 'should fire ready event', ->
      @component.should.have.property '_ready'

    it 'should add events to the element', (done)->
      @component.fireEvent 'test'
      setTimeout =>
        @component.should.have.property "_test"
        done()

    it 'should create sub components', ->
      @component.should.have.property 'Button'
      @component.Button.tagName.should.be.eql 'BTN'

    it 'should create components in order', ->
      @component.querySelector('btn:first-child').should.be.exactly @component.Button2
      @component.querySelector('btn:last-child').should.be.exactly @component.Button

    it 'should create data store', ->
      @component.should.have.property '_data'

  describe 'style', ->
    it 'should throw error for invalid tagname', ->

      Components.css 'login', (css)->

      (-> Components.style '$test').should.throw()
