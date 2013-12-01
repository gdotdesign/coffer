WebSocketStore = require './source/stores/websocket'
graphite = require './source/graphite'
WebSocket       = require 'ws'

graphite.buildClient()

store = new WebSocketStore WebSocket, "ws://graphite-registry.herokuapp.com/", ->
  store.set 'test', {
    css: """

    @keyframes load {
      from {
        opacity: 0;
        background: #fff;
      }
      to {
        opacity: 1;
        background: #ccc;
      }
    }

    body {
      animation: load 2s;
      background: #ccc;
    }

    test {
      display: block;
      border: 1px solid #aaa;
      background: linear-gradient(#fff,#eee);
      padding: 20px;
      font-family: Ubuntu;
      font-weight: bold;
      font-size: 22px
    }
    """
    components:
      Test: {type: 'test4'}
    properties:
      name: (value)-> @textContent = value
    events:
      ready: ->
        @name = 'Hello Word'
      click: (e,create)->
        create 'test3', (el)=> @appendChild el

    }, ->
      store.set 'test4', {}, ->

        graphite.build store,'test'
        ###
        Components.css tagname, (code)->
          code = Autoprefixer.compile(code)
          code = new CleanCSS().minify(code)
          fs.writeFileSync('./bundle.css',code, 'utf-8')
        ###
