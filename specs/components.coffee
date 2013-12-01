Components = require '../source/components'
should = require 'should'
jsdom = require 'jsdom'
Components.document = jsdom.jsdom("<html></html>")
Element = jsdom.level(1, "core").Element

describe 'Components', ->

  describe 'register', ->
    it 'should throw error for invalid tagname', ->
      (-> Components.register '$test').should.throw()

    it 'should call store register', (done)->
      data = {}
      Components.register 'test', data, ->
        Components.store.db.should.have.property 'test'
        Components.store.db.test.should.be.exactly data
        delete Components.store.db.test
        done()

  describe 'create', ->
    before (done)->
      Components.store.db =
        test4: {}
        test: {}
        btn:
          css: "btn { display: block }"
        login:
          css: "login { background: linear-gradient(#fff,#000) }"
          components:
            Button: {type: 'btn', position: 1}
            Button2: {type: 'btn', position: 0}
          properties:
            username: (value,create)->
              create('test4')
              @setAttribute 'username', value
          events:
            ready: (e,create)->
              create('test')
              @_ready = true
            test: ->
              @_test = true
            'test2:*': ->
              @_test2 = true

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

    it 'should call provided function when setting property', ->
      @component.username = "gdot"
      @component.getAttribute('username').should.be.exactly 'gdot'
      @component.username.should.be.exactly 'gdot'

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

    it 'should handle delegated events', (done)->
      @component.Button.fireEvent 'test2'
      setTimeout =>
        @component.should.have.property "_test2"
        done()

    it 'should create sub components', ->
      @component.should.have.property 'Button'
      @component.Button.tagName.should.be.eql 'BTN'

    it 'should create components in order', ->
      @component.querySelector('btn:first-child').should.be.exactly @component.Button2
      @component.querySelector('btn:last-child').should.be.exactly @component.Button

    it 'should create data store', ->
      @component.should.have.property '_data'

  describe 'css', ->
    it 'should throw error for invalid tagname', ->
      (-> Components.css '$test').should.throw()

    it 'should return with css of all components', (done)->
      Components.css 'login', (css)->
        css.indexOf(Components.store.db.btn.css).should.not.be.exactly -1
        css.indexOf(Components.store.db.login.css).should.not.be.exactly -1
        done()

  describe 'style', ->
    it 'should throw error for invalid tagname', ->
      (-> Components.style '$test').should.throw()

    it 'should return object', (done)->
      Components.style 'btn', (obj)->
        obj.should.be.type 'object'
        done()

    it 'should return object that contains the element as a key', (done)->
      Components.style 'btn', (obj)->
        obj.btn.should.not.be.null
        done()

    it 'should return object that conatins the components css', (done)->
      Components.style 'btn', (obj)->
        obj.btn.should.be.exactly Components.store.db.btn.css
        done()

    it 'should return referenced components css also', (done)->
      Components.style 'login', (obj)->
        obj.btn.should.be.exactly Components.store.db.btn.css
        done()

  describe 'geather', ->
    it 'should throw error for invalid tagname', ->
      (-> Components.geather '$test').should.throw()

    it 'should resolve simple component', (done)->
      Components.geather 'btn', (components)->
        components.btn.should.be.type 'object'
        components.btn.should.be.exactly Components.store.db.btn
        done()

    it 'should resolve referenced component', (done)->
      Components.geather 'login', (components)->
        components.btn.should.be.type 'object'
        components.btn.should.be.exactly Components.store.db.btn
        done()

    it 'should resolve referenced component from event', (done)->
      Components.geather 'login', (components)->
        components.test.should.be.type 'object'
        components.test.should.be.exactly Components.store.db.test
        done()

    it 'should resolve referenced component from property', (done)->
      Components.geather 'login', (components)->
        components.test4.should.be.type 'object'
        components.test4.should.be.exactly Components.store.db.test4
        done()
