Registry        = require '../source/registry/registry'
WebSocketStore  = require '../source/stores/websocket'
WebSocket       = require 'ws'

describe 'Registry / WebSocketStore (Integration)', ->
  before (done)->
    @registry = new Registry =>
      @ws = new WebSocketStore WebSocket, "ws://localhost:23578", done

  describe 'get', ->
    it 'should retrun null if there is no component', (done)->
      @ws.get 'test', (args...)=>
        args.should.include(null)
        done()

    it 'should return component if its exsits', (done)->
      @ws.set 'test', {css: 'test{}'}, =>
        @ws.get 'test', (comp)->
          comp.should.have.property 'css'
          comp.css.should.be.exactly 'test{}'
          done()
