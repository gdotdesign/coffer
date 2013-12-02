Graphite = require '../source/graphite'

describe 'Graphite', ->

  it 'should contain stores', ->
    Graphite.should.have.property 'Stores'
    for type in ['Redis','File','Firebase','WebSocket','Memory']
      Graphite.Stores.should.have.property type
      Graphite.Stores[type].should.be.instanceof Function

  describe 'buildClient', ->
    it 'should build a browser client', (done)->
      Graphite.buildClient (code)->
        code.indexOf('ws://graphite-registry.herokuapp.com/').should.not.be.exactly -1
        code.indexOf('Components').should.not.be.exactly -1
        code.indexOf('new WebSocketStore').should.not.be.exactly -1
        code.should.not.match /\n/
        done()

  describe 'buildCSS', ->
    it 'should build css for component', (done)->
      store = new Graphite.Stores.Memory ->
        store.set 'test', {css: 'test{background-color:red}'}, ->
          Graphite.buildCSS store, 'test', (css)->
            css.should.be.exactly 'test{background-color:red}'
            css.should.not.match /\n/
            done()

  describe 'buildJS', ->
    it 'should build css for component', (done)->
      store = new Graphite.Stores.Memory ->
        store.set 'test', {css: 'test{ background-color: red }', events: {test: ->}, properties: {test: ->}}, ->
          Graphite.buildJS store, 'test', (code)->
            code.indexOf('store.db={test:{components:{},events:{test:function(){}},properties:{test:function(){}}}}').should.not.be.exactly -1
            code.should.not.match /\n/
            done()
